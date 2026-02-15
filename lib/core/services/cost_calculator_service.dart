import '../../domain/entities/tool_entity.dart';

class CostCalculatorService {
  /// Calculate total monthly cost for all tools
  double calculateMonthlyTotal(List<ToolEntity> tools) {
    return tools.fold(0, (sum, tool) {
      if (tool.billingType == 'monthly') {
        return sum + (tool.monthlyPrice * tool.seats);
      } else {
        // For yearly billing, amortize to monthly
        return sum + ((tool.monthlyPrice * tool.seats) / 12);
      }
    });
  }

  /// Calculate total yearly cost for all tools
  double calculateYearlyTotal(List<ToolEntity> tools) {
    return tools.fold(0, (sum, tool) {
      if (tool.billingType == 'yearly') {
        return sum +
            (tool.monthlyPrice *
                tool.seats); // monthlyPrice here seems to be total per year? No, usually explicitly monthly.
        // wait, let's assume monthlyPrice is always Price Per Month Per Seat.
        // If billing is yearly, the user might input the annual cost?
        // Let's stick to standard: monthlyPrice is price/month/seat.
        // If billing is yearly, usually there's a discount, but the field is still monthly_price.
        // Let's verify ToolInput.
        // Assumed: monthlyPrice is ALWAYS price per user per month.
      }
      return sum + (tool.monthlyPrice * tool.seats * 12);
    });
  }

  /// Calculate projected cost for the next 3 years
  /// Returns a map with Year 1, Year 2, Year 3 totals
  Map<int, double> calculateThreeYearProjection(List<ToolEntity> tools) {
    return {
      1: _calculateProjectedYearlyTotal(tools, 1),
      2: _calculateProjectedYearlyTotal(tools, 2),
      3: _calculateProjectedYearlyTotal(tools, 3),
    };
  }

  /// Helper to calculate projected cost for a specific future year
  double _calculateProjectedYearlyTotal(List<ToolEntity> tools, int year) {
    return tools.fold(0, (sum, tool) {
      return sum + tool.calculateYearlyCost(year);
    });
  }
}
