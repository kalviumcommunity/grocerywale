import 'package:flutter/material.dart';
import '../models/replenishment_request.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();

    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final currentRole = inventoryService.currentRole;
        final isStoreRole = currentRole == UserRole.storeManager;
        final currentStore = inventoryService.currentStore;
        final allStores = inventoryService.stores;
        final allRequests = inventoryService.requests;

        // Compute role-based statistics
        final activeOrders = allRequests.where((r) {
          if (isStoreRole && r.storeId != currentStore.id) return false;
          return r.status != ReplenishmentStatus.received &&
              r.status != ReplenishmentStatus.cancelled;
        }).length;

        final completedOrders = allRequests.where((r) {
          if (isStoreRole && r.storeId != currentStore.id) return false;
          return r.status == ReplenishmentStatus.received;
        }).length;

        final atRiskCount = inventoryService.fastMovingItemsAtRisk.length;
        final totalCatalogCount = inventoryService.catalog.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile & Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'App Information',
                onPressed: () => _showAppInfoDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: isStoreRole
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFDCFCE7),
                              child: Icon(
                                isStoreRole
                                    ? Icons.storefront
                                    : Icons.warehouse_rounded,
                                size: 32,
                                color: isStoreRole
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inventoryService.currentUserName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    inventoryService.currentRoleTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  inventoryService.currentUserEmail,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.badge_outlined,
                                    size: 15, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  'Employee ID: ${inventoryService.currentEmployeeId}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 15, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  inventoryService.currentUserPhone,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Role Switching Segment
                const Text(
                  'Switch Active Role',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isStoreRole) {
                              inventoryService.setRole(UserRole.storeManager);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Switched to Store Manager profile view'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isStoreRole
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isStoreRole
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront,
                                  size: 18,
                                  color: isStoreRole
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Store Manager',
                                  style: TextStyle(
                                    fontWeight: isStoreRole
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isStoreRole
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isStoreRole) {
                              inventoryService
                                  .setRole(UserRole.warehouseManager);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Switched to Central Warehouse Hub view'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isStoreRole
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !isStoreRole
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warehouse_outlined,
                                  size: 18,
                                  color: !isStoreRole
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Central Warehouse',
                                  style: TextStyle(
                                    fontWeight: !isStoreRole
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !isStoreRole
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Store Location Selector (If in Store Role)
                if (isStoreRole) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assigned Store Location',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${allStores.length} Stores Available',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...allStores.map((store) {
                    final isSelected = store.id == currentStore.id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: isSelected ? 1.5 : 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.grey[200]!,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          if (!isSelected) {
                            inventoryService.setActiveStore(store);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Active store changed to ${store.name}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? const Color(0xFFDBEAFE)
                              : const Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.store,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          store.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${store.code} • ${store.location}',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF2563EB), size: 20)
                            : const Icon(Icons.radio_button_unchecked,
                                color: Colors.grey, size: 20),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Operational Summary Card
                const Text(
                  'Operational Overview',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Active Orders',
                          value: activeOrders.toString(),
                          icon: Icons.sync,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      Container(height: 36, width: 1, color: Colors.grey[200]),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Stockout Risk',
                          value: atRiskCount.toString(),
                          icon: Icons.bolt,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      Container(height: 36, width: 1, color: Colors.grey[200]),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Completed',
                          value: completedOrders.toString(),
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                      Container(height: 36, width: 1, color: Colors.grey[200]),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Total SKUs',
                          value: totalCatalogCount.toString(),
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Preferences & Notification Settings
                const Text(
                  'Alerts & Preferences',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: inventoryService.stockoutAlertsEnabled,
                        onChanged: (val) {
                          inventoryService.toggleStockoutAlerts(val);
                        },
                        title: const Text(
                          'Urgent Stockout Alerts',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Notify immediately when fast-moving items reach critical risk',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bolt,
                              color: Color(0xFFDC2626), size: 20),
                        ),
                        activeThumbColor: const Color(0xFF2563EB),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: inventoryService.autoReorderSuggestions,
                        onChanged: (val) {
                          inventoryService.toggleAutoReorder(val);
                        },
                        title: const Text(
                          'Smart Reorder Suggestions',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Auto-populate recommended restock quantities based on burn rate',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Color(0xFF2563EB), size: 20),
                        ),
                        activeThumbColor: const Color(0xFF2563EB),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: inventoryService.soundAlertsEnabled,
                        onChanged: (val) {
                          inventoryService.toggleSoundAlerts(val);
                        },
                        title: const Text(
                          'Emergency Sound & Haptics',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Audible alerts when critical stock falls under 4 hours remaining',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.volume_up_outlined,
                              color: Color(0xFFD97706), size: 20),
                        ),
                        activeThumbColor: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // System & Demo Tools
                const Text(
                  'System & Demo Management',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.refresh,
                              color: Color(0xFF4B5563), size: 20),
                        ),
                        title: const Text(
                          'Reset Demo Data',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Reload default catalog stock, stores, and test pipeline orders',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _showResetDataDialog(context, inventoryService),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.cloud_done_outlined,
                              color: Color(0xFF16A34A), size: 20),
                        ),
                        title: const Text(
                          'Pipeline Sync Status',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Real-time synchronization active • Local memory cached',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ONLINE',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // App version footer
                Center(
                  child: Text(
                    'StockFlow v1.0.0+1 • Retail Replenishment Suite',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showResetDataDialog(
      BuildContext context, InventoryService inventoryService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Demo Data?'),
        content: const Text(
          'This will restore all stores, inventory counts, and replenishment requests back to their clean initial state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              inventoryService.resetDemoData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo data has been reset to default state!'),
                  backgroundColor: Color(0xFF2563EB),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out of StockFlow? You will need to sign in again to access store inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay Signed In'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.inventory_2, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('About StockFlow'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StockFlow Retail Replenishment Suite',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 6),
            Text(
              'A unified replenishment pipeline bridging grocery store managers with central warehouse dispatching to proactively eradicate stockouts of fast-moving products.',
              style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
            SizedBox(height: 12),
            Text(
              '• Real-time stockout projection based on daily burn rate\n• Shared transparency across Requested, Approved, Dispatched & Received stages\n• 1-Tap emergency restock for fast-moving items',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
