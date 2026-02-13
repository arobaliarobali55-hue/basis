import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tool_model.dart';
import '../models/user_settings_model.dart';
import '../../core/constants/app_constants.dart';

/// Repository for Supabase operations
class SupabaseRepository {
  final SupabaseClient _client;

  SupabaseRepository(this._client);

  // Singleton access to Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // ==================== AUTH OPERATIONS ====================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String companyName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'company_name': companyName},
    );

    // Create default settings for new user
    if (response.user != null) {
      try {
        await _createDefaultSettings(response.user!.id);
      } catch (e) {
        // Log error but don't fail signup
        print('Error creating default settings: $e');
      }
    }

    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    final response = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response;
  }

  /// Update user profile (metadata)
  Future<UserResponse> updateProfile({String? companyName}) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: {'company_name': companyName}),
    );
    return response;
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    if (currentUser?.email != null) {
      await _client.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Delete user settings first
    await _client
        .from(AppConstants.userSettingsTable)
        .delete()
        .eq('user_id', currentUserId!);

    // Delete all user tools
    await _client
        .from(AppConstants.toolsTable)
        .delete()
        .eq('user_id', currentUserId!);

    // Note: Actual user deletion from auth.users requires admin API
    // For now, we'll just sign out after deleting user data
    await signOut();
  }

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ==================== TOOLS OPERATIONS ====================

  /// Fetch all tools for current user
  Future<List<ToolModel>> fetchTools() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(AppConstants.toolsTable)
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ToolModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new tool
  Future<ToolModel> addTool(ToolModel tool) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(AppConstants.toolsTable)
        .insert(tool.toInsertJson())
        .select()
        .single();

    return ToolModel.fromJson(response);
  }

  /// Update a tool
  Future<ToolModel> updateTool(ToolModel tool) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(AppConstants.toolsTable)
        .update(tool.toJson())
        .eq('id', tool.id)
        .eq('user_id', currentUserId!)
        .select()
        .single();

    return ToolModel.fromJson(response);
  }

  /// Delete a tool
  Future<void> deleteTool(String toolId) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from(AppConstants.toolsTable)
        .delete()
        .eq('id', toolId)
        .eq('user_id', currentUserId!);
  }

  /// Get real-time updates for tools
  RealtimeChannel subscribeToTools({
    required void Function(List<ToolModel>) onData,
    required void Function(Object) onError,
  }) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _client
        .channel('tools_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.toolsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId,
          ),
          callback: (payload) async {
            try {
              final tools = await fetchTools();
              onData(tools);
            } catch (e) {
              onError(e);
            }
          },
        )
        .subscribe();
  }

  // ==================== USER SETTINGS OPERATIONS ====================

  /// Fetch user settings
  Future<UserSettingsModel?> fetchUserSettings() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(AppConstants.userSettingsTable)
        .select()
        .eq('user_id', currentUserId!)
        .maybeSingle();

    if (response == null) {
      // Create default settings if none exist
      return await _createDefaultSettings(currentUserId!);
    }

    return UserSettingsModel.fromJson(response);
  }

  /// Create default settings for a user
  Future<UserSettingsModel> _createDefaultSettings(String userId) async {
    final response = await _client
        .from(AppConstants.userSettingsTable)
        .insert({
          'user_id': userId,
          'theme': AppConstants.defaultTheme,
          'currency': AppConstants.defaultCurrency,
          'date_format': AppConstants.defaultDateFormat,
        })
        .select()
        .single();

    return UserSettingsModel.fromJson(response);
  }

  /// Update user settings
  Future<UserSettingsModel> updateUserSettings(
    UserSettingsModel settings,
  ) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(AppConstants.userSettingsTable)
        .update(settings.toUpdateJson())
        .eq('user_id', currentUserId!)
        .select()
        .single();

    return UserSettingsModel.fromJson(response);
  }

  /// Get real-time updates for user settings
  RealtimeChannel subscribeToUserSettings({
    required void Function(UserSettingsModel) onData,
    required void Function(Object) onError,
  }) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _client
        .channel('user_settings_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.userSettingsTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId,
          ),
          callback: (payload) async {
            try {
              final settings = await fetchUserSettings();
              if (settings != null) {
                onData(settings);
              }
            } catch (e) {
              onError(e);
            }
          },
        )
        .subscribe();
  }
}
