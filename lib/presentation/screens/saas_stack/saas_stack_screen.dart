import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/sidebar.dart';

class SaasStackScreen extends ConsumerStatefulWidget {
  const SaasStackScreen({super.key});

  @override
  ConsumerState<SaasStackScreen> createState() => _SaasStackScreenState();
}

class _SaasStackScreenState extends ConsumerState<SaasStackScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateTo(BuildContext context, String route) {
    if (route == '/saas-stack') return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final toolsAsync = ref.watch(toolsProvider);
    final tools = toolsAsync.value ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundColor,
      drawer: isMobile
          ? MobileSidebarDrawer(
              currentRoute: '/saas-stack',
              onNavigate: (route) => _navigateTo(context, route),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              currentRoute: '/saas-stack',
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
                        'SaaS Stack',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/add-tool'),
                        icon: const Icon(Icons.add),
                        label: Text(isMobile ? 'Add' : 'Add Tool'),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: toolsAsync.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : tools.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: AppTheme.textTertiary,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No tools in your stack yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, '/add-tool'),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Your First Tool'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(isMobile ? 16 : 32),
                              itemCount: tools.length,
                              itemBuilder: (context, index) {
                                final tool = tools[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.borderColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: isMobile
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Icon(
                                                    Icons.apps,
                                                    color: AppTheme.primaryColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        tool.toolName,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${tool.category} • ${tool.seats} seats',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                                  color: AppTheme.textSecondary,
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '\$${tool.monthlyPrice.toStringAsFixed(0)} per seat',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${(tool.monthlyPrice * tool.seats).toStringAsFixed(0)}/mo',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.apps,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tool.toolName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${tool.category} • ${tool.seats} seats',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$${(tool.monthlyPrice * tool.seats).toStringAsFixed(0)}/mo',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '\$${tool.monthlyPrice.toStringAsFixed(0)} per seat',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined),
                                              color: AppTheme.textSecondary,
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                );
                              },
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
