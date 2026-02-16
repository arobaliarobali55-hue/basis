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
                        // SaaS Spend Over Time (Large Line Chart)
                        Expanded(
                          flex: 7,
                          child: EntryAnimation(
                            delay: const Duration(milliseconds: 200),
                            child: _SpendOverTimeChart(data: projection),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing24),
                        // Spend by Category (Donut Chart)
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
}

class _KpiSummaryGrid extends StatelessWidget {
  final Map<int, double> projection;

  const _KpiSummaryGrid({required this.projection});

  @override
  Widget build(BuildContext context) {
    // Mocking some data for the KPIs based on the reference
    final monthlySpend = projection[1] != null ? projection[1]! / 12 : 142500.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 5
            : constraints.maxWidth > 800
            ? 3
            : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppTheme.spacing16,
          crossAxisSpacing: AppTheme.spacing16,
          childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.2,
          children: [
            _KpiSummaryCard(
              label: 'TOTAL MONTHLY SPEND',
              value: '\$${(monthlySpend).toStringAsFixed(0)}',
              trend: '+2.4%',
              trendColor: AppTheme.accentColor,
              icon: Icons.account_balance_wallet,
              iconColor: Colors.blue,
            ),
            _KpiSummaryCard(
              label: 'ANNUAL SPEND',
              value: '\$${(projection[1] ?? 1710000).toStringAsFixed(0)}',
              trend: '-1.2%',
              trendColor: AppTheme.errorColor,
              icon: Icons.pie_chart,
              iconColor: Colors.indigo,
            ),
            _KpiSummaryCard(
              label: '3-YEAR PROJECTED',
              value: '\$${(projection[3] ?? 6120000).toStringAsFixed(0)}',
              trend: 'Est.',
              trendColor: AppTheme.textSecondary,
              icon: Icons.calendar_today,
              iconColor: Colors.purple,
            ),
            _KpiSummaryCard(
              label: 'POTENTIAL SAVINGS',
              value: '\$18,420',
              trend: '/mo',
              trendColor: AppTheme.textSecondary,
              icon: Icons.lightbulb_outline,
              iconColor: AppTheme.accentColor,
            ),
            _KpiSummaryCard(
              label: 'COST PER EMPLOYEE',
              value: '\$485',
              trend: 'Avg',
              trendColor: AppTheme.textSecondary,
              icon: Icons.people_outline,
              iconColor: Colors.orange,
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
  final Color trendColor;
  final IconData icon;
  final Color iconColor;

  const _KpiSummaryCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (trend != 'Est.' && trend != 'Avg' && trend != '/mo')
                Row(
                  children: [
                    Icon(
                      trend.startsWith('+')
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
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
    // Generate curved line spots with smooth transitions
    final List<FlSpot> spots = [
      const FlSpot(0, 120000),
      const FlSpot(1, 145000),
      const FlSpot(2, 138000),
      const FlSpot(3, 160000),
      const FlSpot(4, 155000),
      const FlSpot(5, 172000),
      const FlSpot(6, 168000),
    ];

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
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SaaS Spend Over Time',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxWidth < 600 ? 16 : 20,
                    ),
                  ),
                  if (constraints.maxWidth > 500)
                    Row(
                      children: [
                        _ChartLegendItem(
                          label: 'Actual',
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        _ChartLegendItem(
                          label: 'Projected',
                          color: AppTheme.primaryColor.withOpacity(0.4),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppTheme.spacing32),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppTheme.borderColor, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: AppTheme.surfaceColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.primaryColor.withOpacity(0.0),
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
          children: [
            Text(
              '84%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Text(
              'Optimized',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Financial Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxWidth < 600 ? 18 : null,
                        ),
                      ),
                      Text(
                        'Personalized recommendations',
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: constraints.maxWidth < 600 ? 11 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: Text(
                    constraints.maxWidth < 600
                        ? 'View All'
                        : 'View All Analysis',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppTheme.spacing24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: const [
                  Expanded(
                    child: _AiInsightActionCard(
                      title: 'Consolidate CRM Tools',
                      description:
                          'Salesforce and HubSpot licenses overlap in your Marketing department.',
                      saving: '\$1,240/mo',
                      icon: Icons.merge_type,
                      iconColor: Colors.orange,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing24),
                  Expanded(
                    child: _AiInsightActionCard(
                      title: 'Unused Seat Cleanup',
                      description:
                          'Found 24 unused seats in your Figma Enterprise account.',
                      saving: '\$360/mo',
                      icon: Icons.person_off_outlined,
                      iconColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing24),
                  Expanded(
                    child: _AiInsightActionCard(
                      title: 'Annual Plan Savings',
                      description:
                          'Switching Datadog to an annual contract could save up to 15%.',
                      saving: '\$8,400/yr',
                      icon: Icons.calendar_month_outlined,
                      iconColor: Colors.green,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: const [
                  _AiInsightActionCard(
                    title: 'Consolidate CRM Tools',
                    description:
                        'Salesforce and HubSpot licenses overlap in your Marketing department.',
                    saving: '\$1,240/mo',
                    icon: Icons.merge_type,
                    iconColor: Colors.orange,
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  _AiInsightActionCard(
                    title: 'Unused Seat Cleanup',
                    description:
                        'Found 24 unused seats in your Figma Enterprise account.',
                    saving: '\$360/mo',
                    icon: Icons.person_off_outlined,
                    iconColor: Colors.blue,
                  ),
                  SizedBox(height: AppTheme.spacing16),
                  _AiInsightActionCard(
                    title: 'Annual Plan Savings',
                    description:
                        'Switching Datadog to an annual contract could save up to 15%.',
                    saving: '\$8,400/yr',
                    icon: Icons.calendar_month_outlined,
                    iconColor: Colors.green,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _AiInsightActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String saving;
  final IconData icon;
  final Color iconColor;

  const _AiInsightActionCard({
    required this.title,
    required this.description,
    required this.saving,
    required this.icon,
    required this.iconColor,
  });

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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: AppTheme.spacing20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EST. SAVINGS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    saving,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceHighlight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: const Text(
                  'Take Action',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
