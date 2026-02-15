import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../../core/services/consolidation_service.dart';

class IntelligenceDashboard extends ConsumerWidget {
  const IntelligenceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cost Intelligence')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3-Year Cost Projection Card
            const _CostProjectionCard(),
            const SizedBox(height: AppTheme.spacing16),

            // Waste Detection Section
            const _WasteDetectionSection(),
            const SizedBox(height: AppTheme.spacing16),

            // Consolidation Suggestions
            const _ConsolidationSection(),
          ],
        ),
      ),
    );
  }
}

class _CostProjectionCard extends ConsumerWidget {
  const _CostProjectionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projection = ref.watch(threeYearProjectionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3-Year Cost Projection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Estimated total cost for the next 3 years based on current growth.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing24),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (projection[3] ?? 1000) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppTheme.surfaceColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '\$${rod.toY.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Year 1';
                              break;
                            case 1:
                              text = 'Year 2';
                              break;
                            case 2:
                              text = 'Year 3';
                              break;
                            default:
                              text = '';
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ), // Hide Y axis labels for cleaner look
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: projection[1] ?? 0,
                          color: AppTheme.primaryColor,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: projection[2] ?? 0,
                          color: AppTheme.secondaryColor,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: projection[3] ?? 0,
                          color: AppTheme.warningColor, // Highlight growth
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WasteDetectionSection extends ConsumerWidget {
  const _WasteDetectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasteData = ref.watch(wasteDetectionProvider);
    final unused = wasteData['unused'] as List<dynamic>;
    final duplicates =
        wasteData['duplicates']
            as Map<
              String,
              dynamic
            >; // Map<String, List<String>> basically? No dynamic.
    // Actually provider returns dynamic map.

    if (wasteData['totalWarnings'] == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hidden Costs Detected',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.errorColor),
        ),
        const SizedBox(height: AppTheme.spacing8),
        ...unused.map(
          (u) => _WarningCard(
            title: 'Unused Licenses',
            message: u.toString(),
            icon: Icons.person_off,
          ),
        ),
        ...(duplicates as Map).entries.map(
          (e) => _WarningCard(
            title: 'Duplicate Tools in ${e.key}',
            message:
                'You have multiple tools for this category: ${(e.value as List).join(", ")}',
            icon: Icons.copy,
          ),
        ),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _WarningCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.errorColor.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.errorColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.errorColor,
          ),
        ),
        subtitle: Text(message),
      ),
    );
  }
}

class _ConsolidationSection extends ConsumerWidget {
  const _ConsolidationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(consolidationSuggestionsProvider);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consolidation Suggestions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.accentColor),
        ),
        const SizedBox(height: AppTheme.spacing8),
        ...suggestions.map(
          (s) => Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb, color: AppTheme.accentColor),
              title: Text(
                s.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(s.description),
              trailing: Chip(
                label: Text(
                  s.potentialSavings,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _getSavingsColor(s.potentialSavings),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getSavingsColor(String savings) {
    switch (savings) {
      case 'High':
        return AppTheme.accentColor;
      case 'Medium':
        return AppTheme.warningColor;
      default:
        return AppTheme.secondaryColor;
    }
  }
}
