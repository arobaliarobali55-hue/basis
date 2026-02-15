import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/ai_insight_card.dart';

class AiInsightsScreen extends ConsumerWidget {
  const AiInsightsScreen({super.key});

  void _navigateTo(BuildContext context, String route) {
    if (route == '/ai-insights') return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wasteData = ref.watch(wasteDetectionProvider);
    final monthlyCost = ref.watch(totalMonthlyCostProvider);
    final yearlyCost = ref.watch(totalYearlyCostProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          Sidebar(
            currentRoute: '/ai-insights',
            onNavigate: (route) => _navigateTo(context, route),
          ),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'AI Financial Insights',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      _BetaBadge(),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            _SummaryCard(
                              title: 'Potential Annual Savings',
                              value: '\$${(yearlyCost * 0.15).toStringAsFixed(0)}',
                              subtitle: 'Based on AI analysis',
                              icon: Icons.savings_outlined,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 16),
                            _SummaryCard(
                              title: 'Active Alerts',
                              value: '${wasteData['totalWarnings']}',
                              subtitle: 'Requires attention',
                              icon: Icons.notifications_active_outlined,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 16),
                            _SummaryCard(
                              title: 'Optimization Score',
                              value: '78',
                              subtitle: 'Out of 100',
                              icon: Icons.trending_up,
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Insights List
                        const Text(
                          'Priority Insights',
                          style: TextStyle(
                            fontSize: 20,
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
                                title: 'Unused Licenses Detected',
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
                                savingsLabel: 'Potential Consolidation',
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
                              savingsValue: '\$${(yearlyCost * 0.12).toStringAsFixed(0)}',
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
                              savingsLabel: 'Potential Consolidation',
                              savingsValue: '\$${(monthlyCost * 0.03).toStringAsFixed(0)}',
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

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
        ),
        child: Row(
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
      ),
    );
  }
}
