import '../../domain/entities/tool_entity.dart';

class HiddenCostDetectorService {
  /// Detect unused licenses across all tools
  /// Returns a list of strings describing the inefficiencies
  List<String> detectUnusedLicenses(List<ToolEntity> tools) {
    final suggestions = <String>[];
    double totalWastedMoneyPerMonth = 0;

    for (var tool in tools) {
      if (tool.seats > 0 && tool.assignedSeats < tool.seats) {
        final unusedCount = tool.seats - tool.assignedSeats;
        final wastedCost = unusedCount * tool.monthlyPrice;
        totalWastedMoneyPerMonth += wastedCost;

        suggestions.add(
          '${tool.toolName}: $unusedCount unused licenses (Saving: \$${wastedCost.toStringAsFixed(2)}/mo)',
        );
      }
    }

    if (totalWastedMoneyPerMonth > 0) {
      suggestions.insert(
        0,
        'Total Potential Savings: \$${totalWastedMoneyPerMonth.toStringAsFixed(2)}/mo from unused seats',
      );
    }

    return suggestions;
  }

  /// Detect duplicate tools in the same category
  Map<String, List<String>> detectDuplicateTools(List<ToolEntity> tools) {
    final categoryMap = <String, List<String>>{};
    final duplicates = <String, List<String>>{};

    for (var tool in tools) {
      if (!categoryMap.containsKey(tool.category)) {
        categoryMap[tool.category] = [];
      }
      categoryMap[tool.category]!.add(tool.toolName);
    }

    categoryMap.forEach((category, toolNames) {
      if (toolNames.length > 1) {
        duplicates[category] = toolNames;
      }
    });

    return duplicates;
  }

  /// Detect tools with high growth rates (potential future cost explosions)
  List<String> detectGrowthSpikes(
    List<ToolEntity> tools, {
    double threshold = 20.0,
  }) {
    return tools
        .where((tool) => tool.growthRate > threshold)
        .map(
          (tool) =>
              '${tool.toolName} is growing at ${tool.growthRate}%/year. Monitor closely.',
        )
        .toList();
  }
}
