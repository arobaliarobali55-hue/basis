import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:basis/core/theme/app_theme.dart';
import 'package:basis/presentation/widgets/common/custom_card.dart';

class BreakEvenScreen extends ConsumerStatefulWidget {
  const BreakEvenScreen({super.key});

  @override
  ConsumerState<BreakEvenScreen> createState() => _BreakEvenScreenState();
}

class _BreakEvenScreenState extends ConsumerState<BreakEvenScreen> {
  // Model state
  double _monthlySaasCost = 500;
  double _upfrontBuildCost = 15000;
  double _monthlyMaintenance = 100;

  @override
  Widget build(BuildContext context) {
    // Calculate break-even
    final monthlyDiff = _monthlySaasCost - _monthlyMaintenance;
    double breakEvenMonths = 0;
    if (monthlyDiff > 0) {
      breakEvenMonths = _upfrontBuildCost / monthlyDiff;
    }

    final breakEvenYears = breakEvenMonths / 12;

    return Scaffold(
      appBar: AppBar(title: const Text('Break-Even Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Interactive Modeling',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Adjust parameters to see when "Building" becomes cheaper than "Buying".',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Main Layout: Inputs + Chart (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildVisuals(breakEvenYears, monthlyDiff),
                      ),
                      const SizedBox(width: AppTheme.spacing24),
                      Expanded(flex: 1, child: _buildControls()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildVisuals(breakEvenYears, monthlyDiff),
                      const SizedBox(height: AppTheme.spacing24),
                      _buildControls(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parameters', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacing24),

          // SaaS Cost Slider
          _buildSlider(
            label: 'Monthly SaaS Cost',
            value: _monthlySaasCost,
            min: 100,
            max: 5000,
            divisions: 49,
            prefix: '\$',
            onChanged: (val) => setState(() => _monthlySaasCost = val),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Build Cost Slider
          _buildSlider(
            label: 'Upfront Build Cost',
            value: _upfrontBuildCost,
            min: 1000,
            max: 50000,
            divisions: 49,
            prefix: '\$',
            onChanged: (val) => setState(() => _upfrontBuildCost = val),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Maintenance Slider
          _buildSlider(
            label: 'Monthly Maintenance',
            value: _monthlyMaintenance,
            min: 0,
            max: 2000,
            divisions: 40,
            prefix: '\$',
            onChanged: (val) => setState(() => _monthlyMaintenance = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String prefix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '$prefix${value.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.borderColor,
            thumbColor: Colors.white,
            overlayColor: AppTheme.primaryColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildVisuals(double breakEvenYears, double monthlyDiff) {
    return Column(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetric(
                'Break-Even Time',
                monthlyDiff > 0
                    ? '${breakEvenYears.toStringAsFixed(1)} Years'
                    : 'Never',
                monthlyDiff > 0 ? Icons.timer : Icons.error_outline,
                monthlyDiff > 0 ? AppTheme.accentColor : AppTheme.errorColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: _buildSummaryMetric(
                '3-Year Savings',
                _calculateSavings(3, monthlyDiff),
                Icons.savings,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Chart
        CustomCard(
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cumulative Cost Over Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Expanded(child: _buildChart(breakEvenYears)),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateSavings(int years, double monthlyDiff) {
    if (monthlyDiff <= 0) return '\$0';
    final savings = (monthlyDiff * 12 * years) - _upfrontBuildCost;
    return savings > 0
        ? '\$${savings.toStringAsFixed(0)}'
        : '-\$${savings.abs().toStringAsFixed(0)}';
  }

  Widget _buildSummaryMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(double breakEvenYears) {
    final showBreakEven = breakEvenYears > 0 && breakEvenYears <= 5;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor.withOpacity(0.5),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Year ${val.toInt()}'),
              ),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        lineBarsData: [
          // SaaS Cost Line
          LineChartBarData(
            spots: List.generate(6, (i) {
              return FlSpot(i.toDouble(), _monthlySaasCost * 12 * i);
            }),
            isCurved: false,
            color: AppTheme.secondaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Build Cost Line
          LineChartBarData(
            spots: List.generate(6, (i) {
              return FlSpot(
                i.toDouble(),
                _upfrontBuildCost + (_monthlyMaintenance * 12 * i),
              );
            }),
            isCurved: false,
            color: AppTheme.accentColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '\$${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          verticalLines: showBreakEven
              ? [
                  VerticalLine(
                    x: breakEvenYears,
                    color: AppTheme.textPrimary,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) => 'Break-even',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
