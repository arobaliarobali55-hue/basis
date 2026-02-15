import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basis/core/theme/app_theme.dart';
import 'package:basis/presentation/providers/app_providers.dart';
import 'package:basis/presentation/screens/dashboard/intelligence_dashboard.dart';
import 'package:basis/presentation/screens/inventory/inventory_screen.dart';
import 'package:basis/presentation/screens/calculator/rent_vs_own_screen.dart';
import 'package:basis/presentation/screens/tools/break_even_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    IntelligenceDashboard(),
    InventoryScreen(),
    RentVsOwnScreen(),
    BreakEvenScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Navigation Shell
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop: Navigation Rail (Sidebar)
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Theme.of(context).cardColor,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Image.asset(
                      'assets/icon.png',
                      height: 40,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.account_balance_wallet,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/settings'),
                          tooltip: 'Settings',
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () {
                            ref.read(supabaseRepositoryProvider).signOut();
                          },
                          tooltip: 'Logout',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Overview'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2),
                      label: Text('Stack'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.compare_arrows),
                      selectedIcon: Icon(Icons.compare_arrows),
                      label: Text('Strategy'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Modeling'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile: Bottom Navigation Bar
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Stack',
                ),
                NavigationDestination(
                  icon: Icon(Icons.compare_arrows),
                  selectedIcon: Icon(Icons.compare_arrows),
                  label: 'Strategy',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Modeling',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
