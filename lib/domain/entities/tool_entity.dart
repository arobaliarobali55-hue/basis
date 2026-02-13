/// Domain entity representing a SaaS tool
class ToolEntity {
  final String id;
  final String userId;
  final String toolName;
  final String category;
  final double monthlyPrice;
  final int seats;
  final String billingType; // 'monthly' or 'yearly'
  final double growthRate; // percentage (e.g., 15.0 for 15%)
  final DateTime createdAt;

  const ToolEntity({
    required this.id,
    required this.userId,
    required this.toolName,
    required this.category,
    required this.monthlyPrice,
    required this.seats,
    required this.billingType,
    required this.growthRate,
    required this.createdAt,
  });

  /// Calculate yearly cost for a specific year (0-indexed)
  /// Year 0 = Current year
  /// Year 1 = Next year (with growth applied once)
  /// Year 2 = Year after (with growth applied twice)
  double calculateYearlyCost(int year) {
    if (year < 0) return 0;

    // Apply compound growth: price × (1 + growthRate)^year
    final growthMultiplier = _pow(1 + (growthRate / 100), year);
    final adjustedMonthlyPrice = monthlyPrice * growthMultiplier;

    return adjustedMonthlyPrice * 12;
  }

  /// Calculate total cost over N years
  double calculateTotalCost(int years) {
    double total = 0;
    for (int i = 0; i < years; i++) {
      total += calculateYearlyCost(i);
    }
    return total;
  }

  /// Helper for power calculation (avoiding dart:math for simplicity)
  double _pow(double base, int exponent) {
    if (exponent == 0) return 1;
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  /// Check if this tool has potential waste indicators
  List<String> getWasteWarnings() {
    final warnings = <String>[];

    if (seats == 0) {
      warnings.add('Zero seats allocated - potential unused subscription');
    }

    if (growthRate > 20.0) {
      warnings.add('Growth rate exceeds 20% - review pricing strategy');
    }

    return warnings;
  }

  /// Copy with method for immutability
  ToolEntity copyWith({
    String? id,
    String? userId,
    String? toolName,
    String? category,
    double? monthlyPrice,
    int? seats,
    String? billingType,
    double? growthRate,
    DateTime? createdAt,
  }) {
    return ToolEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      toolName: toolName ?? this.toolName,
      category: category ?? this.category,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      seats: seats ?? this.seats,
      billingType: billingType ?? this.billingType,
      growthRate: growthRate ?? this.growthRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
