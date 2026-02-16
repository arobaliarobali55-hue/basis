import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basis/presentation/screens/dashboard/intelligence_dashboard.dart';
import 'package:basis/presentation/screens/inventory/inventory_screen.dart';
import 'package:basis/presentation/screens/calculator/rent_vs_own_screen.dart';
import 'package:basis/presentation/screens/tools/break_even_screen.dart';
import 'package:basis/presentation/widgets/layout/sidebar.dart';
import 'package:basis/presentation/widgets/layout/top_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const IntelligenceDashboard(),
    const InventoryScreen(),
    const RentVsOwnScreen(),
    const BreakEvenScreen(),
    const Center(child: Text('AI Insights')), // Placeholder
    const Center(child: Text('Reports')), // Placeholder
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
          // Desktop: Professional Sidebar + Content
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onDestinationSelected,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const TopBar(),
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
