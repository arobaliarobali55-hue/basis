import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/ai_insight_card.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateTo(BuildContext context, String route) {
    if (route == '/ai-insights') return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final wasteData = ref.watch(wasteDetectionProvider);
    final monthlyCost = ref.watch(totalMonthlyCostProvider);
    final yearlyCost = ref.watch(totalYearlyCostProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundColor,
      drawer: isMobile
          ? MobileSidebarDrawer(
              currentRoute: '/ai-insights',
              onNavigate: (route) => _navigateTo(context, route),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              currentRoute: '/ai-insights',
              onNavigate: (route) => _navigateTo(context, route),
            ),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 12 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isMobile)
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                      Text(
                        'AI Insights',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const _BetaBadge(),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        _buildSummaryCards(
                          wasteData: wasteData,
                          monthlyCost: monthlyCost,
                          yearlyCost: yearlyCost,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: isMobile ? 24 : 32),

                        // Insights List
                        Text(
                          'Priority Insights',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (wasteData['totalWarnings'] > 0) ...[
                          if (wasteData['zeroSeatsCount'] > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AiInsightCard(
                                priority: InsightPriority.high,
                                icon: Icons.people_outline,
                                title: 'Unused Licenses',
                                description:
                                    '${wasteData['zeroSeatsCount']} tools have zero active users but are still being billed monthly. Consider downgrading or canceling these subscriptions.',
                                savingsLabel: 'Est. Monthly Leak',
                                savingsValue: '\$${(monthlyCost * 0.08).toStringAsFixed(0)}',
                                savingsColor: AppTheme.errorColor,
                                onAction: () => Navigator.pushNamed(context, '/saas-stack'),
                              ),
                            ),
                          if (wasteData['highGrowthCount'] > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AiInsightCard(
                                priority: InsightPriority.medium,
                                icon: Icons.trending_up,
                                title: 'High Growth Alert',
                                description:
                                    '${wasteData['highGrowthCount']} tools have increased by more than 20% in cost over the last quarter. Review pricing tiers and negotiate discounts.',
                                savingsLabel: 'Potential Savings',
                                savingsValue: '\$${(monthlyCost * 0.05).toStringAsFixed(0)}',
                                savingsColor: AppTheme.warningColor,
                                onAction: () {},
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AiInsightCard(
                              priority: InsightPriority.low,
                              icon: Icons.calendar_today,
                              title: 'Upcoming Renewals',
                              description:
                                  '3 major contracts (AWS, Salesforce, Slack) are renewing in the next 60 days. Consider switching to annual billing for 15-20% discounts.',
                              savingsLabel: 'Est. Annual Saving',
                              savingsValue: '\$12,450',
                              savingsColor: AppTheme.accentColor,
                              onAction: () {},
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AiInsightCard(
                              priority: InsightPriority.medium,
                              icon: Icons.merge_type,
                              title: 'Tool Function Overlap',
                              description:
                                  'Miro, LucidChart, and FigJam are all being used for diagramming. Consider consolidating to a single tool for better pricing.',
                              savingsLabel: 'Potential Savings',
                              savingsValue: '\$320',
                              savingsColor: AppTheme.warningColor,
                              onAction: () {},
                            ),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.borderColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.accentColor,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'All Clear!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No optimization opportunities detected. Your SaaS stack is well-managed.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildSummaryCards({
    required Map<String, dynamic> wasteData,
    required double monthlyCost,
    required double yearlyCost,
    required bool isMobile,
  }) {
    final cards = [
      _SummaryCard(
        title: 'Potential Savings',
        value: '\$${(yearlyCost * 0.15).toStringAsFixed(0)}',
        subtitle: 'Annual',
        icon: Icons.savings_outlined,
        color: AppTheme.accentColor,
        isCompact: isMobile,
      ),
      _SummaryCard(
        title: 'Active Alerts',
        value: '${wasteData['totalWarnings']}',
        subtitle: 'Need attention',
        icon: Icons.notifications_active_outlined,
        color: AppTheme.warningColor,
        isCompact: isMobile,
      ),
      _SummaryCard(
        title: 'Score',
        value: '78',
        subtitle: 'Out of 100',
        icon: Icons.trending_up,
        color: AppTheme.primaryColor,
        isCompact: isMobile,
      ),
    ];

    if (isMobile) {
      return Row(
        children: cards.map((card) => Expanded(child: card)).toList(),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompact;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 24),
      margin: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: isCompact
          ? Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
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
