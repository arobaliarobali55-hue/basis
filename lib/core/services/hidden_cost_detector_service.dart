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
    final spikes = <String>[];
    for (final tool in tools) {
      if (tool.growthRate > threshold) {
        spikes.add(
          '${tool.toolName} is growing at ${tool.growthRate}%/year (High)',
        );
      }
    }
    return spikes;
  }

  /// Detect tools with pricing above market average
  Map<String, String> detectPriceAnomalies(List<ToolEntity> tools) {
    final anomalies = <String, String>{};
    // Hardcoded market benchmarks (avg price per seat/user)
    final marketRates = {
      'slack': 8.0,
      'zoom': 15.0,
      'jira': 7.5,
      'notion': 10.0,
      'figma': 12.0,
      'github': 4.0,
      'salesforce': 25.0,
      'hubspot': 50.0,
    };

    for (final tool in tools) {
      final name = tool.toolName.toLowerCase();
      // Simple exact match or contains check
      for (final entry in marketRates.entries) {
        if (name.contains(entry.key)) {
          // Calculate effective price per seat if possible
          if (tool.seats > 0) {
            final pricePerSeat = tool.monthlyPrice / tool.seats;
            // If price is 50% higher than benchmark
            if (pricePerSeat > entry.value * 1.5) {
              anomalies[tool.toolName] =
                  'Paying \$${pricePerSeat.toStringAsFixed(2)}/seat vs market avg \$${entry.value}/seat';
            }
          }
        }
      }
    }
    return anomalies;
  }
}
