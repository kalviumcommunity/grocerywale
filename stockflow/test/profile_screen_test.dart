import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockflow/models/store_info.dart';
import 'package:stockflow/screens/profile_screen.dart';
import 'package:stockflow/services/inventory_service.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    late InventoryService service;

    setUp(() {
      service = InventoryService();
      service.resetDemoData();
      service.setRole(UserRole.storeManager);
    });

    testWidgets('ProfileScreen renders user details, store and metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header info
      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Store Manager'), findsWidgets);
      expect(find.text('sarah.jenkins@grocerywale.com'), findsOneWidget);
      expect(find.textContaining('Employee ID: GW-STR-101'), findsOneWidget);

      // Operational overview
      expect(find.text('Operational Overview'), findsOneWidget);
      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Stockout Risk'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Total SKUs'), findsOneWidget);

      // Alerts & Preferences
      expect(find.text('Urgent Stockout Alerts'), findsOneWidget);
      expect(find.text('Smart Reorder Suggestions'), findsOneWidget);
      expect(find.text('Emergency Sound & Haptics'), findsOneWidget);

      // System & Demo Tools
      expect(find.text('Reset Demo Data'), findsOneWidget);
      expect(find.text('Pipeline Sync Status'), findsOneWidget);

      // Log Out
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Toggles role switching between Store Manager and Warehouse',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Central Warehouse
      await tester.tap(find.text('Central Warehouse'));
      await tester.pumpAndSettle();

      expect(service.currentRole, UserRole.warehouseManager);
      expect(find.text('Marcus Vance'), findsOneWidget);
      expect(find.text('Central Warehouse Supervisor'), findsOneWidget);
      expect(find.text('marcus.vance@grocerywale.com'), findsOneWidget);
      expect(find.textContaining('GW-WH-001'), findsOneWidget);

      // Switch back to Store Manager
      await tester.tap(find.text('Store Manager'));
      await tester.pumpAndSettle();

      expect(service.currentRole, UserRole.storeManager);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
    });

    testWidgets('Toggles store locations within Store Manager role',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Westside Supercenter'), findsOneWidget);

      // Select Westside Supercenter
      await tester.tap(find.text('Westside Supercenter'));
      await tester.pumpAndSettle();

      expect(service.currentStore.name, 'Westside Supercenter');
      expect(service.currentStore.code, 'STR-102');
      expect(find.text('David Chen'), findsOneWidget);
    });

    testWidgets('Toggles preference switches and calls service handlers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.soundAlertsEnabled, isFalse);

      // Find switch for Emergency Sound & Haptics and scroll to it
      final soundSwitch = find.widgetWithText(
        SwitchListTile,
        'Emergency Sound & Haptics',
      );
      expect(soundSwitch, findsOneWidget);

      await tester.ensureVisible(soundSwitch);
      await tester.pumpAndSettle();

      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();

      expect(service.soundAlertsEnabled, isTrue);
    });

    testWidgets('Reset demo data opens dialog and restores initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final resetBtn = find.text('Reset Demo Data');
      await tester.ensureVisible(resetBtn);
      await tester.pumpAndSettle();

      // Tap Reset Demo Data
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      expect(find.text('Reset Demo Data?'), findsOneWidget);
      expect(find.text('Reset Data'), findsOneWidget);

      // Confirm Reset
      await tester.tap(find.text('Reset Data'));
      await tester.pumpAndSettle();

      expect(find.text('Demo data has been reset to default state!'), findsOneWidget);
    });

    testWidgets('Logout button opens confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final logoutBtn = find.text('Log Out');
      await tester.ensureVisible(logoutBtn);
      await tester.pumpAndSettle();

      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Stay Signed In'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Stay Signed In'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Logout'), findsNothing);
    });
  });
}
