import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/metric_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);
    final monthlyCost = ref.watch(totalMonthlyCostProvider);
    final yearlyCost = ref.watch(totalYearlyCostProvider);
    final projection = ref.watch(threeYearProjectionProvider);
    final monthlyData = ref.watch(monthlyProjectionProvider);
    final wasteData = ref.watch(wasteDetectionProvider);

    final isLoading = toolsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final repository = ref.read(supabaseRepositoryProvider);
              await repository.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(toolsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Cost Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Metrics Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Monthly Cost',
                            value: monthlyCost,
                            icon: Icons.calendar_today,
                            iconColor: AppTheme.primaryColor,
                            isLoading: isLoading,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: MetricCard(
                            title: 'Yearly Cost',
                            value: yearlyCost,
                            icon: Icons.calendar_month,
                            iconColor: AppTheme.secondaryColor,
                            isLoading: isLoading,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: MetricCard(
                            title: '3-Year Total',
                            value: projection['total'] ?? 0,
                            icon: Icons.trending_up,
                            iconColor: AppTheme.accentColor,
                            subtitle: 'With growth projections',
                            isLoading: isLoading,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      MetricCard(
                        title: 'Monthly Cost',
                        value: monthlyCost,
                        icon: Icons.calendar_today,
                        iconColor: AppTheme.primaryColor,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      MetricCard(
                        title: 'Yearly Cost',
                        value: yearlyCost,
                        icon: Icons.calendar_month,
                        iconColor: AppTheme.secondaryColor,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      MetricCard(
                        title: '3-Year Total',
                        value: projection['total'] ?? 0,
                        icon: Icons.trending_up,
                        iconColor: AppTheme.accentColor,
                        subtitle: 'With growth projections',
                        isLoading: isLoading,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Waste Warnings
              if (wasteData['totalWarnings'] > 0) ...[
                Card(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            Text(
                              'Waste Detected',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        ...((wasteData['warnings'] as List).take(3).map((
                          warning,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacing8,
                            ),
                            child: Text(
                              '• ${warning['message']}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          );
                        })),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),
              ],

              // Cost Projection Chart
              Text(
                '36-Month Cost Projection',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing24),
                  child: SizedBox(
                    height: 300,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _CostChart(monthlyData: monthlyData),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-tool');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add SaaS Tool'),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/calculator');
                  },
                  icon: const Icon(Icons.calculate),
                  label: const Text('Rent vs Own Calculator'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostChart extends StatelessWidget {
  final List<double> monthlyData;

  const _CostChart({required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty || monthlyData.every((v) => v == 0)) {
      return Center(
        child: Text(
          'Add tools to see cost projections',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textTertiary),
        ),
      );
    }

    final maxY = monthlyData.reduce((a, b) => a > b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.borderColor.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 6,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 12 == 0) {
                  final year = (value.toInt() ~/ 12) + 1;
                  return Text(
                    'Y$year',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
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
        minX: 0,
        maxX: 35,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              monthlyData.length,
              (index) => FlSpot(index.toDouble(), monthlyData[index]),
            ),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
