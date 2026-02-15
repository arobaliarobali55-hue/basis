class BreakEvenService {
  /// Calculate the break-even point in years
  /// Returns the number of years until custom build becomes cheaper than SaaS
  double calculateBreakEvenYears({
    required double yearlySaasCost,
    required double customBuildCost,
    required double yearlyMaintenanceCost,
  }) {
    // SaaS Cost(t) = yearlySaasCost * t
    // Build Cost(t) = customBuildCost + (yearlyMaintenanceCost * t)
    // Break-even when: yearlySaasCost * t = customBuildCost + yearlyMaintenanceCost * t
    // t * (yearlySaasCost - yearlyMaintenanceCost) = customBuildCost
    // t = customBuildCost / (yearlySaasCost - yearlyMaintenanceCost)

    if (yearlySaasCost <= yearlyMaintenanceCost) {
      return -1; // Never breaks even (SaaS is cheaper or equal to maintenance)
    }

    return customBuildCost / (yearlySaasCost - yearlyMaintenanceCost);
  }

  /// Generate comparison data for N years
  List<RentVsOwnYearlyData> generateComparisonData({
    required double yearlySaasCost,
    required double customBuildCost,
    required double yearlyMaintenanceCost,
    int years = 5,
  }) {
    final data = <RentVsOwnYearlyData>[];

    for (int i = 1; i <= years; i++) {
      // Simple linear projection for now.
      // Could add inflation/growth logic later.
      final saasTotal = yearlySaasCost * i;
      final ownTotal = customBuildCost + (yearlyMaintenanceCost * i);

      data.add(
        RentVsOwnYearlyData(
          year: i,
          saasCumulativeCost: saasTotal,
          ownCumulativeCost: ownTotal,
        ),
      );
    }

    return data;
  }
}

class RentVsOwnYearlyData {
  final int year;
  final double saasCumulativeCost;
  final double ownCumulativeCost;

  RentVsOwnYearlyData({
    required this.year,
    required this.saasCumulativeCost,
    required this.ownCumulativeCost,
  });
}
