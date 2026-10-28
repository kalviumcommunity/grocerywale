import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import 'dashboard_screen.dart';
import 'pipeline_screen.dart';
import 'inventory_screen.dart';
import 'warehouse_console_screen.dart';
import 'profile_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;
  final inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final atRiskCount = inventoryService.fastMovingItemsAtRisk.length;

        final screens = [
          DashboardScreen(
            onNavigateTab: (index) {
              setState(() => _currentIndex = index);
            },
          ),
          const PipelineScreen(),
          const InventoryScreen(),
          const WarehouseConsoleScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: const Color(0xFF6B7280),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.sync_alt_rounded),
                activeIcon: Icon(Icons.sync_alt_rounded),
                label: 'Pipeline',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: atRiskCount > 0,
                  label: Text('$atRiskCount'),
                  child: const Icon(Icons.inventory_2_outlined),
                ),
                activeIcon: Badge(
                  isLabelVisible: atRiskCount > 0,
                  label: Text('$atRiskCount'),
                  child: const Icon(Icons.inventory_2),
                ),
                label: 'Inventory',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.warehouse_outlined),
                activeIcon: Icon(Icons.warehouse),
                label: 'Warehouse',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
