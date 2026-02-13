import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_repository.dart';
import '../../data/models/tool_model.dart';
import '../../data/models/user_settings_model.dart';
import '../../domain/usecases/finance_engine.dart';
import '../../core/constants/app_constants.dart';

// ==================== REPOSITORY PROVIDERS ====================

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase repository provider
final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseRepository(client);
});

// ==================== AUTH PROVIDERS ====================

/// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(supabaseRepositoryProvider);
  return repository.authStateChanges.map((state) => state.session?.user);
});

/// Auth state provider (simple boolean)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// ==================== TOOLS PROVIDERS ====================

/// Tools list provider
final toolsProvider = StreamProvider<List<ToolModel>>((ref) async* {
  final repository = ref.watch(supabaseRepositoryProvider);

  // Wait for authentication
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    yield [];
    return;
  }

  // Initial fetch
  final tools = await repository.fetchTools();
  yield tools;

  // Subscribe to real-time updates
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    try {
      final updatedTools = await repository.fetchTools();
      yield updatedTools;
    } catch (e) {
      // Keep previous data on error
    }
  }
});

/// Add tool provider
final addToolProvider = Provider<Future<void> Function(ToolModel)>((ref) {
  return (tool) async {
    final repository = ref.read(supabaseRepositoryProvider);
    await repository.addTool(tool);
    // Refresh tools list
    ref.invalidate(toolsProvider);
  };
});

/// Update tool provider
final updateToolProvider = Provider<Future<void> Function(ToolModel)>((ref) {
  return (tool) async {
    final repository = ref.read(supabaseRepositoryProvider);
    await repository.updateTool(tool);
    // Refresh tools list
    ref.invalidate(toolsProvider);
  };
});

/// Delete tool provider
final deleteToolProvider = Provider<Future<void> Function(String)>((ref) {
  return (toolId) async {
    final repository = ref.read(supabaseRepositoryProvider);
    await repository.deleteTool(toolId);
    // Refresh tools list
    ref.invalidate(toolsProvider);
  };
});

// ==================== FINANCE PROVIDERS ====================

/// Total monthly cost provider
final totalMonthlyCostProvider = Provider<double>((ref) {
  final toolsAsync = ref.watch(toolsProvider);
  return toolsAsync.when(
    data: (tools) => FinanceEngine.calculateTotalMonthlyCost(tools),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Total yearly cost provider
final totalYearlyCostProvider = Provider<double>((ref) {
  final toolsAsync = ref.watch(toolsProvider);
  return toolsAsync.when(
    data: (tools) => FinanceEngine.calculateTotalYearlyCost(tools),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// 3-year projection provider
final threeYearProjectionProvider = Provider<Map<String, double>>((ref) {
  final toolsAsync = ref.watch(toolsProvider);
  return toolsAsync.when(
    data: (tools) => FinanceEngine.calculate3YearProjection(tools),
    loading: () => {'year1': 0, 'year2': 0, 'year3': 0, 'total': 0},
    error: (_, __) => {'year1': 0, 'year2': 0, 'year3': 0, 'total': 0},
  );
});

/// Monthly projection for chart (36 months)
final monthlyProjectionProvider = Provider<List<double>>((ref) {
  final toolsAsync = ref.watch(toolsProvider);
  return toolsAsync.when(
    data: (tools) => FinanceEngine.getMonthlyProjection(tools),
    loading: () => List.filled(36, 0.0),
    error: (_, __) => List.filled(36, 0.0),
  );
});

/// Waste detection provider
final wasteDetectionProvider = Provider<Map<String, dynamic>>((ref) {
  final toolsAsync = ref.watch(toolsProvider);
  return toolsAsync.when(
    data: (tools) => FinanceEngine.detectWaste(tools),
    loading: () => {
      'warnings': [],
      'zeroSeatsCount': 0,
      'highGrowthCount': 0,
      'duplicateCategories': [],
      'totalWarnings': 0,
    },
    error: (_, __) => {
      'warnings': [],
      'zeroSeatsCount': 0,
      'highGrowthCount': 0,
      'duplicateCategories': [],
      'totalWarnings': 0,
    },
  );
});

// ==================== RENT VS OWN CALCULATOR ====================

/// Rent vs Own calculator state
class RentVsOwnState {
  final double competitorMonthlyPrice;
  final double competitorYearlyIncrease;
  final double activationFee;
  final double flatMonthlyFee;

  RentVsOwnState({
    this.competitorMonthlyPrice = 0,
    this.competitorYearlyIncrease = 0,
    this.activationFee = 0,
    this.flatMonthlyFee = 0,
  });

  RentVsOwnState copyWith({
    double? competitorMonthlyPrice,
    double? competitorYearlyIncrease,
    double? activationFee,
    double? flatMonthlyFee,
  }) {
    return RentVsOwnState(
      competitorMonthlyPrice:
          competitorMonthlyPrice ?? this.competitorMonthlyPrice,
      competitorYearlyIncrease:
          competitorYearlyIncrease ?? this.competitorYearlyIncrease,
      activationFee: activationFee ?? this.activationFee,
      flatMonthlyFee: flatMonthlyFee ?? this.flatMonthlyFee,
    );
  }
}

/// Rent vs Own state provider
final rentVsOwnStateProvider = StateProvider<RentVsOwnState>((ref) {
  return RentVsOwnState();
});

/// Rent vs Own calculation result provider
final rentVsOwnResultProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(rentVsOwnStateProvider);

  if (state.competitorMonthlyPrice == 0 && state.flatMonthlyFee == 0) {
    return {
      'breakEvenMonth': null,
      'threeYearSavings': 0.0,
      'monthlyData': <int, Map<String, double>>{},
      'competitorTotal': 0.0,
      'ownTotal': 0.0,
    };
  }

  return FinanceEngine.calculateRentVsOwn(
    competitorMonthlyPrice: state.competitorMonthlyPrice,
    competitorYearlyIncrease: state.competitorYearlyIncrease,
    activationFee: state.activationFee,
    flatMonthlyFee: state.flatMonthlyFee,
  );
});

// ==================== USER SETTINGS PROVIDERS ====================

/// User settings provider
final userSettingsProvider = StreamProvider<UserSettingsModel?>((ref) async* {
  final repository = ref.watch(supabaseRepositoryProvider);

  // Wait for authentication
  final userAsync = await ref.watch(currentUserProvider.future);
  if (userAsync == null) {
    yield null;
    return;
  }

  // Initial fetch
  try {
    final settings = await repository.fetchUserSettings();
    yield settings;
  } catch (e) {
    yield null;
  }

  // Subscribe to real-time updates
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    try {
      final updatedSettings = await repository.fetchUserSettings();
      yield updatedSettings;
    } catch (e) {
      // Keep previous data on error
    }
  }
});

/// Theme mode provider (derived from settings)
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settingsAsync = ref.watch(userSettingsProvider);
  return settingsAsync.when(
    data: (settings) {
      if (settings == null) return ThemeMode.dark;
      return settings.theme == 'light' ? ThemeMode.light : ThemeMode.dark;
    },
    loading: () => ThemeMode.dark,
    error: (_, __) => ThemeMode.dark,
  );
});

/// Currency provider (derived from settings)
final currencyProvider = Provider<String>((ref) {
  final settingsAsync = ref.watch(userSettingsProvider);
  return settingsAsync.when(
    data: (settings) => settings?.currency ?? AppConstants.defaultCurrency,
    loading: () => AppConstants.defaultCurrency,
    error: (_, __) => AppConstants.defaultCurrency,
  );
});

/// Currency symbol provider
final currencySymbolProvider = Provider<String>((ref) {
  final currency = ref.watch(currencyProvider);
  return AppConstants.currencySymbols[currency] ?? '\$';
});

/// Update user settings provider
final updateUserSettingsProvider =
    Provider<Future<void> Function(UserSettingsModel)>((ref) {
      return (settings) async {
        final repository = ref.read(supabaseRepositoryProvider);
        await repository.updateUserSettings(settings);
        // Refresh settings
        ref.invalidate(userSettingsProvider);
      };
    });

/// Update theme provider
final updateThemeProvider = Provider<Future<void> Function(String)>((ref) {
  return (theme) async {
    final settingsAsync = ref.read(userSettingsProvider);
    final settings = settingsAsync.value;
    if (settings != null) {
      final updatedSettings = settings.copyWith(theme: theme);
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.updateUserSettings(updatedSettings);
      // Invalidate providers to trigger rebuild
      ref.invalidate(userSettingsProvider);
    }
  };
});

/// Update currency provider
final updateCurrencyProvider = Provider<Future<void> Function(String)>((ref) {
  return (currency) async {
    final settingsAsync = ref.read(userSettingsProvider);
    final settings = settingsAsync.value;
    if (settings != null) {
      final updatedSettings = settings.copyWith(currency: currency);
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.updateUserSettings(updatedSettings);
      // Invalidate providers to trigger rebuild
      ref.invalidate(userSettingsProvider);
    }
  };
});

/// Delete account provider
final deleteAccountProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(supabaseRepositoryProvider);
    await repository.deleteAccount();
  };
});
