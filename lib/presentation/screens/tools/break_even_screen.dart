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
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacing24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modeling & Break-even',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                ),
                          ),
                          Text(
                            'Enterprise ROI modeling and decision matrix',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Export ROI Model'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Modeling & Break-even',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enterprise ROI modeling and decision matrix',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Export ROI Model'),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Main Layout: Inputs + Chart (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _buildVisuals(breakEvenYears, monthlyDiff),
                      ),
                      const SizedBox(width: AppTheme.spacing24),
                      Expanded(flex: 3, child: _buildControls()),
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
    // Calculate break-even for the verdict
    final monthlyDiff = _monthlySaasCost - _monthlyMaintenance;
    double breakEvenMonths = 0;
    if (monthlyDiff > 0) {
      breakEvenMonths = _upfrontBuildCost / monthlyDiff;
    }
    final breakEvenYears = breakEvenMonths / 12;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('PARAMETERS', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: AppTheme.spacing24),

          _buildSlider(
            label: 'Custom Build Cost',
            value: _upfrontBuildCost,
            min: 1000,
            max: 150000,
            divisions: 149,
            prefix: '\$',
            onChanged: (val) => setState(() => _upfrontBuildCost = val),
          ),
          const SizedBox(height: AppTheme.spacing24),
          _buildSlider(
            label: 'Current SaaS Cost',
            value: _monthlySaasCost,
            min: 100,
            max: 10000,
            divisions: 99,
            prefix: '\$',
            onChanged: (val) => setState(() => _monthlySaasCost = val),
          ),
          const SizedBox(height: AppTheme.spacing24),
          _buildSlider(
            label: 'Maintenance Rate',
            value: _monthlyMaintenance,
            min: 0,
            max: 5000,
            divisions: 50,
            prefix: '\$',
            onChanged: (val) => setState(() => _monthlyMaintenance = val),
          ),

          const SizedBox(height: AppTheme.spacing32),
          const Divider(),
          const SizedBox(height: AppTheme.spacing24),

          _buildVerdict(breakEvenYears),
        ],
      ),
    );
  }

  Widget _buildVerdict(double breakEvenYears) {
    final recommended = breakEvenYears > 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECOMMENDATION', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (recommended ? AppTheme.accentColor : AppTheme.warningColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color:
                  (recommended ? AppTheme.accentColor : AppTheme.warningColor)
                      .withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                recommended ? Icons.check_circle_outline : Icons.info_outline,
                color: recommended
                    ? AppTheme.accentColor
                    : AppTheme.warningColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommended
                      ? 'Continue SaaS model. Break-even exceeds 36 months.'
                      : 'Consider custom build. ROI achieved within ${breakEvenYears.toStringAsFixed(1)} years.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: recommended
                        ? AppTheme.accentColor
                        : AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'BREAK-EVEN',
                          value: monthlyDiff > 0
                              ? '${breakEvenYears.toStringAsFixed(1)} Yrs'
                              : 'N/A',
                          icon: Icons.timer_outlined,
                          iconColor: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing20),
                      Expanded(
                        child: _StatCard(
                          label: 'ROI TIMELINE',
                          value: monthlyDiff > 0 ? 'Positive' : 'Negative',
                          icon: Icons.show_chart,
                          iconColor: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing20),
                      Expanded(
                        child: _StatCard(
                          label: 'RISK SCORE',
                          value: breakEvenYears > 4 ? 'Low' : 'Med',
                          icon: Icons.gpp_maybe_outlined,
                          iconColor: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                ],
              );
            } else {
              return Column(
                children: [
                  _StatCard(
                    label: 'BREAK-EVEN',
                    value: monthlyDiff > 0
                        ? '${breakEvenYears.toStringAsFixed(1)} Yrs'
                        : 'N/A',
                    icon: Icons.timer_outlined,
                    iconColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'ROI TIMELINE',
                    value: monthlyDiff > 0 ? 'Positive' : 'Negative',
                    icon: Icons.show_chart,
                    iconColor: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'RISK SCORE',
                    value: breakEvenYears > 4 ? 'Low' : 'Med',
                    icon: Icons.gpp_maybe_outlined,
                    iconColor: Colors.amber,
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                ],
              );
            }
          },
        ),

        // Chart
        Container(
          height: 450,
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CUMULATIVE COST COMPARISON',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: AppTheme.spacing32),
              Expanded(child: _buildChart(breakEvenYears)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(double breakEvenYears) {
    final showBreakEven = breakEvenYears > 0 && breakEvenYears <= 5;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppTheme.borderColor,
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
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Year ${val.toInt()}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (val, meta) => Text(
                '\$${(val / 1000).toStringAsFixed(0)}k',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
        minX: 0,
        maxX: 5,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              6,
              (i) => FlSpot(i.toDouble(), _monthlySaasCost * 12 * i),
            ),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          LineChartBarData(
            spots: List.generate(
              6,
              (i) => FlSpot(
                i.toDouble(),
                _upfrontBuildCost + (_monthlyMaintenance * 12 * i),
              ),
            ),
            isCurved: true,
            color: AppTheme.accentColor,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.accentColor.withOpacity(0.1),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          verticalLines: showBreakEven
              ? [
                  VerticalLine(
                    x: breakEvenYears,
                    color: AppTheme.textPrimary,
                    strokeWidth: 2,
                    dashArray: [10, 5],
                    label: VerticalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) => 'Break-even Point',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
