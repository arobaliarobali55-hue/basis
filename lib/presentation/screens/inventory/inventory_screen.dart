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
      appBar: AppBar(
        title: const Text('SaaS Stack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-tool'),
          ),
        ],
      ),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummary(context, tools),
                const SizedBox(height: AppTheme.spacing24),
                Text(
                  'Active Subscriptions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacing16),
                _buildInventoryList(context, tools),
              ],
            ),
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
    final totalSeats = tools.fold(0, (sum, t) => sum + t.seats);

    return Row(
      children: [
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Monthly Spend',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(symbol: '\$').format(totalCost),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Active Seats',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  totalSeats.toString(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryList(BuildContext context, List<ToolModel> tools) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop/Tablet: Table
          return CustomCard(
            padding: EdgeInsets.zero,
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Tool')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Seats')),
                DataColumn(label: Text('Monthly Cost')),
                DataColumn(label: Text('Growth')),
              ],
              rows: tools.map((tool) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceHighlight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.api, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            tool.toolName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(tool.category)),
                    DataCell(Text('${tool.seats}')),
                    DataCell(
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                        ).format(tool.monthlyPrice * tool.seats),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            tool.growthRate >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: 16,
                            color: tool.growthRate >= 0
                                ? AppTheme.accentColor
                                : AppTheme.errorColor,
                          ),
                          const SizedBox(width: 4),
                          Text('${tool.growthRate}%'),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        } else {
          // Mobile: List
          return Column(
            children: tools
                .map((tool) => _buildMobileToolCard(context, tool))
                .toList(),
          );
        }
      },
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
