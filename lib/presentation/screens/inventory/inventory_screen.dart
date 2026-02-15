import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basis/core/theme/app_theme.dart';
import 'package:basis/presentation/providers/app_providers.dart';
import 'package:basis/presentation/widgets/common/custom_card.dart';
import 'package:basis/data/models/tool_model.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: toolsAsync.when(
        data: (tools) {
          if (tools.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppTheme.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tools tracked yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add-tool'),
                    child: const Text('Add Your First Tool'),
                  ),
                ],
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.spacing24),
              ),

              // Summary Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSummary(context, tools),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.spacing32),
              ),

              // Filters & Actions
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing24,
                ),
                sliver: SliverToBoxAdapter(child: _buildFilters(context)),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppTheme.spacing16),
              ),

              // Table
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: _buildInventoryList(context, tools),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<ToolModel> tools) {
    final totalCost = tools.fold(
      0.0,
      (sum, t) => sum + (t.monthlyPrice * t.seats),
    );
    final activeTools = tools.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'TOTAL MONTHLY SPEND',
            value: NumberFormat.currency(symbol: '\$').format(totalCost),
            icon: Icons.account_balance_wallet,
            iconColor: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacing24),
        Expanded(
          child: _StatCard(
            label: 'ACTIVE TOOLS',
            value: activeTools.toString(),
            icon: Icons.inventory_2,
            iconColor: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacing24),
        Expanded(
          child: _StatCard(
            label: 'AVG. COST / TOOL',
            value: NumberFormat.currency(
              symbol: '\$',
            ).format(totalCost / (activeTools > 0 ? activeTools : 1)),
            icon: Icons.analytics,
            iconColor: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search tools...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _FilterButton(label: 'Category', icon: Icons.filter_list),
        const SizedBox(width: 12),
        _FilterButton(label: 'Status', icon: Icons.bolt),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add-tool'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Tool'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryList(BuildContext context, List<ToolModel> tools) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          columnSpacing: 24,
          columns: const [
            DataColumn(
              label: Text(
                'TOOL NAME',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'CATEGORY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'PLAN',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'USERS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'MONTHLY',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'ANNUAL',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'STATUS',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: tools.map((tool) {
            final annual = tool.monthlyPrice * tool.seats * 12;
            final monthly = tool.monthlyPrice * tool.seats;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      _ToolLogo(name: tool.toolName),
                      const SizedBox(width: 12),
                      Text(
                        tool.toolName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(tool.category)),
                DataCell(const Text('Enterprise')), // Placeholder
                DataCell(Text('${tool.seats}')),
                DataCell(
                  Text(NumberFormat.currency(symbol: '\$').format(monthly)),
                ),
                DataCell(
                  Text(NumberFormat.currency(symbol: '\$').format(annual)),
                ),
                DataCell(
                  _StatusBadge(
                    status: tool.growthRate > 50 ? 'Risk' : 'Active',
                  ),
                ),
              ],
            );
          }).toList(),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
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

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FilterButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ToolLogo extends StatelessWidget {
  final String name;
  const _ToolLogo({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isRisk = status == 'Risk';
    final color = isRisk ? AppTheme.errorColor : AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMobileToolCard(BuildContext context, ToolModel tool) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.api),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.toolName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tool.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    symbol: '\$',
                  ).format(tool.monthlyPrice * tool.seats),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tool.seats} Seats',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Text(
                      'Growth: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${tool.growthRate}%',
                      style: TextStyle(
                        color: tool.growthRate >= 0
                            ? AppTheme.accentColor
                            : AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
