import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import 'package:basis/presentation/widgets/common/entry_animation.dart';

class IntelligenceDashboard extends ConsumerWidget {
  const IntelligenceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);
    final projection = ref.watch(fiveYearProjectionProvider);
    final departmentData = ref.watch(departmentBreakdownProvider);
    final isLoading = toolsAsync.isLoading;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing24)),

          // Top Toggle and Range Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing24,
              ),
              child: _buildHeaderControls(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing24)),

          // KPI Grid Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            sliver: SliverToBoxAdapter(
              child: EntryAnimation(
                delay: const Duration(milliseconds: 100),
                child: _KpiSummaryGrid(projection: projection),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing32)),

          // Main Charts Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SaaS Spend Over Time (Large Chart)
                        Expanded(
                          flex: 7,
                          child: EntryAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: _SpendOverTimeChart(data: projection),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing24),
                        // Spend by Category
                        Expanded(
                          flex: 3,
                          child: EntryAnimation(
                            delay: const Duration(milliseconds: 300),
                            child: _SpendCategorySection(data: departmentData),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        EntryAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: _SpendOverTimeChart(data: projection),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: _SpendCategorySection(data: departmentData),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing32)),

          // AI Financial Insights Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
            sliver: const SliverToBoxAdapter(
              child: EntryAnimation(
                delay: Duration(milliseconds: 400),
                child: _AiFinancialInsightsSection(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacing48)),
        ],
      ),
    );
  }

  Widget _buildHeaderControls(BuildContext context) {
    return Row(
      children: [
        // View Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: const [
              _ToggleItem(label: '3Y Projection', isSelected: true),
              _ToggleItem(label: '5Y View', isSelected: false),
            ],
          ),
        ),
        const Spacer(),
        // Date Range
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'FY 2024 - 2027',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _ToggleItem({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

class _KpiSummaryGrid extends StatelessWidget {
  final Map<int, double> projection;

  const _KpiSummaryGrid({required this.projection});

  @override
  Widget build(BuildContext context) {
    final monthlySpend = projection[1] != null ? projection[1]! / 12 : 142500.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppTheme.spacing16,
          crossAxisSpacing: AppTheme.spacing16,
          childAspectRatio: 2.2,
          children: [
            _KpiSummaryCard(
              label: 'MONTHLY SPEND',
              value: '\$${(monthlySpend / 1000).toStringAsFixed(0)}k',
              trend: '+2.4%',
              progress: 0.7,
              progressColor: Colors.blue,
            ),
            _KpiSummaryCard(
              label: 'ANNUAL ARR',
              value:
                  '\$${((projection[1] ?? 1710000) / 1000000).toStringAsFixed(1)}M',
              trend: '-1.2%',
              progress: 0.4,
              progressColor: AppTheme.accentColor,
            ),
          ],
        );
      },
    );
  }
}

class _KpiSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final double progress;
  final Color progressColor;

  const _KpiSummaryCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: trend.startsWith('+')
                      ? AppTheme.errorColor
                      : AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpendOverTimeChart extends StatelessWidget {
  final Map<int, double> data;

  const _SpendOverTimeChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SaaS Spend Over Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _ChartLegendItem(
                    label: 'Actual',
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 16),
                  _ChartLegendItem(
                    label: 'Projected',
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: 200000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const quarters = [
                          'Q1 23',
                          'Q3 23',
                          'Q1 24',
                          'Q3 24',
                          'Q1 25',
                          'Q3 25',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < quarters.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              quarters[value.toInt()],
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeGroupData(0, 100000, isProjected: false),
                  _makeGroupData(1, 130000, isProjected: false),
                  _makeGroupData(2, 110000, isProjected: false),
                  _makeGroupData(3, 160000, isProjected: false, isNow: true),
                  _makeGroupData(4, 150000, isProjected: true),
                  _makeGroupData(5, 180000, isProjected: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isProjected = false,
    bool isNow = false,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isProjected
              ? const Color(0xFF1E3A8A).withOpacity(0.4)
              : const Color(0xFF1E3A8A),
          width: 25,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
      showingTooltipIndicators: isNow ? [0] : [],
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _ChartLegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SpendCategorySection extends StatelessWidget {
  final Map<String, double> data;

  const _SpendCategorySection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spend by Category',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacing32),
          SizedBox(height: 200, child: _SpendCategoryDonut(data: data)),
          const SizedBox(height: AppTheme.spacing32),
          _CategoryLegend(data: data),
        ],
      ),
    );
  }
}

class _SpendCategoryDonut extends StatelessWidget {
  final Map<String, double> data;

  const _SpendCategoryDonut({required this.data});

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections = [];
    int i = 0;
    data.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: AppTheme.chartColors[i % AppTheme.chartColors.length],
          value: value,
          title: '',
          radius: 20,
          showTitle: false,
        ),
      );
      i++;
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 60,
            sectionsSpace: 4,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '32',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              'TOOLS',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final Map<String, double> data;

  const _CategoryLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.entries.take(4).map((e) {
        final index = data.keys.toList().indexOf(e.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      AppTheme.chartColors[index % AppTheme.chartColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                e.key,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${(e.value / 1000).toStringAsFixed(0)}k',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AiFinancialInsightsSection extends StatelessWidget {
  const _AiFinancialInsightsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF3B82F6), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'AI Financial Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: const Text(
                '3 ACTIONS',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing24),
        const _AiInsightActionCard(
          title: 'Tool Redundancy Detected',
          description:
              'Overlap between Zoom and MS Teams in Marketing department.',
          saving: '-\$2.4k/mo',
          actionLabel: 'CONSOLIDATION PLAN',
          icon: Icons.warning_rounded,
          iconColor: Colors.amber,
        ),
        const SizedBox(height: AppTheme.spacing16),
        const _AiInsightActionCard(
          title: 'Unused Seat Leakage',
          description:
              '18 Salesforce seats have been inactive for > 60 days. Downgrade recommended.',
          saving: '-\$4.8k/mo',
          actionLabel: 'AUTO-DOWNGRADE',
          icon: Icons.flash_on_rounded,
          iconColor: Colors.red,
        ),
      ],
    );
  }
}

class _AiInsightActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String saving;
  final String actionLabel;
  final IconData icon;
  final Color iconColor;

  const _AiInsightActionCard({
    required this.title,
    required this.description,
    required this.saving,
    required this.actionLabel,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      saving,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
