import '../entities/tool_entity.dart';

/// Financial calculation engine for cost projections and analysis
class FinanceEngine {
  /// Calculate total monthly cost across all tools
  static double calculateTotalMonthlyCost(List<ToolEntity> tools) {
    return tools.fold(0.0, (sum, tool) => sum + tool.monthlyPrice);
  }

  /// Calculate total yearly cost (current year) across all tools
  static double calculateTotalYearlyCost(List<ToolEntity> tools) {
    return tools.fold(0.0, (sum, tool) => sum + tool.calculateYearlyCost(0));
  }

  /// Calculate 3-year projection for all tools
  static Map<String, double> calculate3YearProjection(List<ToolEntity> tools) {
    double year1 = 0;
    double year2 = 0;
    double year3 = 0;

    for (final tool in tools) {
      year1 += tool.calculateYearlyCost(0);
      year2 += tool.calculateYearlyCost(1);
      year3 += tool.calculateYearlyCost(2);
    }

    return {
      'year1': year1,
      'year2': year2,
      'year3': year3,
      'total': year1 + year2 + year3,
    };
  }

  /// Get monthly breakdown for chart (36 months with growth)
  static List<double> getMonthlyProjection(List<ToolEntity> tools) {
    final monthlyData = List<double>.filled(36, 0.0);

    for (final tool in tools) {
      for (int month = 0; month < 36; month++) {
        final year = month ~/ 12; // Integer division to get year
        final yearlyCost = tool.calculateYearlyCost(year);
        monthlyData[month] += yearlyCost / 12;
      }
    }

    return monthlyData;
  }

  /// Detect waste across all tools
  static Map<String, dynamic> detectWaste(List<ToolEntity> tools) {
    final warnings = <Map<String, dynamic>>[];
    final categoryCounts = <String, int>{};
    int zeroSeatsCount = 0;
    int highGrowthCount = 0;

    for (final tool in tools) {
      // Count categories
      categoryCounts[tool.category] = (categoryCounts[tool.category] ?? 0) + 1;

      // Check for zero seats
      if (tool.seats == 0) {
        zeroSeatsCount++;
        warnings.add({
          'toolName': tool.toolName,
          'type': 'zero_seats',
          'message': 'Zero seats allocated',
        });
      }

      // Check for high growth rate
      if (tool.growthRate > 20.0) {
        highGrowthCount++;
        warnings.add({
          'toolName': tool.toolName,
          'type': 'high_growth',
          'message': 'Growth rate exceeds 20%',
        });
      }
    }

    // Check for duplicate categories
    final duplicateCategories = <String>[];
    categoryCounts.forEach((category, count) {
      if (count > 1) {
        duplicateCategories.add(category);
        warnings.add({
          'category': category,
          'count': count,
          'type': 'duplicate_category',
          'message': '$count tools in $category category',
        });
      }
    });

    return {
      'warnings': warnings,
      'zeroSeatsCount': zeroSeatsCount,
      'highGrowthCount': highGrowthCount,
      'duplicateCategories': duplicateCategories,
      'totalWarnings': warnings.length,
    };
  }

  /// Calculate Rent vs Own comparison
  static Map<String, dynamic> calculateRentVsOwn({
    required double competitorMonthlyPrice,
    required double competitorYearlyIncrease, // percentage
    required double activationFee,
    required double flatMonthlyFee,
  }) {
    final monthlyData = <int, Map<String, double>>{};
    double competitorTotal = activationFee;
    double ownTotal = 0;

    // Calculate for 36 months
    for (int month = 1; month <= 36; month++) {
      final year = (month - 1) ~/ 12;

      // Competitor cost with yearly increase
      final yearMultiplier = _pow(1 + (competitorYearlyIncrease / 100), year);
      final competitorMonthly = competitorMonthlyPrice * yearMultiplier;
      competitorTotal += competitorMonthly;

      // Own cost (flat fee)
      ownTotal += flatMonthlyFee;

      monthlyData[month] = {
        'competitor': competitorTotal,
        'own': ownTotal,
        'savings': competitorTotal - ownTotal,
      };
    }

    // Find break-even month
    int? breakEvenMonth;
    for (int month = 1; month <= 36; month++) {
      if (monthlyData[month]!['savings']! > 0) {
        breakEvenMonth = month;
        break;
      }
    }

    final threeYearSavings = monthlyData[36]!['savings']!;

    return {
      'breakEvenMonth': breakEvenMonth,
      'threeYearSavings': threeYearSavings,
      'monthlyData': monthlyData,
      'competitorTotal': monthlyData[36]!['competitor'],
      'ownTotal': monthlyData[36]!['own'],
    };
  }

  /// Helper for power calculation
  static double _pow(double base, int exponent) {
    if (exponent == 0) return 1;
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
