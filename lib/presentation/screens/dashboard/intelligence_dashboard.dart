import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';

class IntelligenceDashboard extends ConsumerWidget {
  const IntelligenceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);
    final projection = ref.watch(fiveYearProjectionProvider);
    final departmentData = ref.watch(departmentBreakdownProvider);
    final isLoading = toolsAsync.isLoading;

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
            const SizedBox(height: AppTheme.spacing24),

            // Advanced Intelligence Visualizations
            if (!isLoading) ...[
              _DepartmentBarChart(data: departmentData),
              const SizedBox(height: AppTheme.spacing24),
              _FiveYearProjectionChart(data: projection),
              const SizedBox(height: AppTheme.spacing32),
            ] else
              const Center(child: CircularProgressIndicator()),
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
                      getTooltipColor: (_) => AppTheme.surfaceColor,
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
                            meta: meta,
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
      color: AppTheme.errorColor.withValues(alpha: 0.1),
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

class _DepartmentBarChart extends StatelessWidget {
  final Map<String, double> data;

  const _DepartmentBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Cost Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.surfaceColor,
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
                          final index = value.toInt();
                          if (index >= 0 && index < data.keys.length) {
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                data.keys.elementAt(index),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(data.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.values.elementAt(index),
                          color: AppTheme
                              .chartColors[index % AppTheme.chartColors.length],
                          width: 25,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiveYearProjectionChart extends StatelessWidget {
  final Map<int, double> data;

  const _FiveYearProjectionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxY = data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '5-Year Scalability Forecast',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacing24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          'Year ${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 5,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.accentColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor.withOpacity(0.3),
                            AppTheme.accentColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
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
