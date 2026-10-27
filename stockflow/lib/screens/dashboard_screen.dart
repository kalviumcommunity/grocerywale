import 'package:flutter/material.dart';
import '../models/replenishment_request.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import '../widgets/fast_moving_alert_banner.dart';
import '../widgets/status_badge.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final inventoryService = InventoryService();

    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final currentRole = inventoryService.currentRole;
        final isStoreRole = currentRole == UserRole.storeManager;
        final currentStore = inventoryService.currentStore;
        final atRiskFastMovers = inventoryService.fastMovingItemsAtRisk;
        final roleRequests = inventoryService.getRequestsForRole(
          onlyCurrentStore: isStoreRole,
        );

        final requestedCount =
            roleRequests.where((r) => r.status == ReplenishmentStatus.requested).length;
        final approvedCount =
            roleRequests.where((r) => r.status == ReplenishmentStatus.approved).length;
        final dispatchedCount =
            roleRequests.where((r) => r.status == ReplenishmentStatus.dispatched).length;
        final receivedCount =
            roleRequests.where((r) => r.status == ReplenishmentStatus.received).length;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  isStoreRole ? Icons.storefront_outlined : Icons.warehouse_outlined,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStoreRole ? currentStore.name : 'Central Warehouse Hub',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isStoreRole
                            ? 'Store Mgr: ${currentStore.managerName}'
                            : 'Central Warehouse Dispatch Console',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Store / Role switch popup menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Switch Store / Role',
                onSelected: (val) {
                  if (val == 'role_store') {
                    inventoryService.setRole(UserRole.storeManager);
                  } else if (val == 'role_warehouse') {
                    inventoryService.setRole(UserRole.warehouseManager);
                  } else if (val.startsWith('store_')) {
                    final store = inventoryService.stores.firstWhere(
                      (s) => s.id == val,
                      orElse: () => inventoryService.currentStore,
                    );
                    inventoryService.setActiveStore(store);
                    inventoryService.setRole(UserRole.storeManager);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('SWITCH ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  PopupMenuItem(
                    value: 'role_store',
                    child: Row(
                      children: [
                        Icon(
                          Icons.store,
                          color: isStoreRole ? const Color(0xFF2563EB) : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Store Manager View',
                          style: TextStyle(
                            fontWeight: isStoreRole ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'role_warehouse',
                    child: Row(
                      children: [
                        Icon(
                          Icons.warehouse,
                          color: !isStoreRole ? const Color(0xFF2563EB) : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Central Warehouse View',
                          style: TextStyle(
                            fontWeight: !isStoreRole ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('SWITCH STORE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  ...inventoryService.stores.map(
                    (s) => PopupMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.name} (${s.code})',
                        style: TextStyle(
                          fontWeight: s.id == currentStore.id && isStoreRole
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role indicator banner
                Container(
                  width: double.infinity,
                  color: isStoreRole ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isStoreRole ? Icons.store : Icons.warehouse,
                        size: 16,
                        color: isStoreRole ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isStoreRole
                            ? 'Viewing as Store Manager for ${currentStore.name}'
                            : 'Viewing as Central Warehouse Manager (All Stores)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isStoreRole ? const Color(0xFF1E40AF) : const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fast-Moving Stockout Risk Banner
                FastMovingAlertBanner(
                  atRiskItems: atRiskFastMovers,
                  onViewDetails: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(2); // Navigate to inventory tab
                    }
                  },
                ),

                // Metric Cards Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Stockout Risk',
                          value: atRiskFastMovers.length.toString(),
                          subtitle: 'Fast-moving SKUs',
                          color: const Color(0xFFDC2626),
                          icon: Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'In Transit',
                          value: dispatchedCount.toString(),
                          subtitle: 'Dispatched to store',
                          color: const Color(0xFF0284C7),
                          icon: Icons.local_shipping,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Pending',
                          value: requestedCount.toString(),
                          subtitle: 'Awaiting approval',
                          color: const Color(0xFFD97706),
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiCard(
                          title: 'Approved',
                          value: approvedCount.toString(),
                          subtitle: 'Packing at warehouse',
                          color: const Color(0xFF4F46E5),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Pipeline Quick Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shared Visibility Pipeline',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (onNavigateTab != null)
                            InkWell(
                              onTap: () => onNavigateTab!(1),
                              child: const Text(
                                'View Pipeline →',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPipelineBadge('Requested', requestedCount, const Color(0xFFB45309)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              _buildPipelineBadge('Approved', approvedCount, const Color(0xFF4338CA)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              _buildPipelineBadge('Dispatched', dispatchedCount, const Color(0xFF0369A1)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              _buildPipelineBadge('Received', receivedCount, const Color(0xFF15803D)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Action Buttons
                if (isStoreRole)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateRequestScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('Create Restock Order'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (atRiskFastMovers.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CreateRequestScreen(
                                      preselectedItem: atRiskFastMovers.first,
                                      isEmergency: true,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All fast-moving items have healthy inventory!'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.bolt, color: Color(0xFFDC2626), size: 18),
                            label: const Text(
                              'Emergency Restock',
                              style: TextStyle(color: Color(0xFFDC2626)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDC2626)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (onNavigateTab != null) {
                                onNavigateTab!(3); // Navigate to Warehouse Console tab
                              }
                            },
                            icon: const Icon(Icons.warehouse, size: 18),
                            label: const Text('Dispatch Console'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (onNavigateTab != null) {
                                onNavigateTab!(1); // Navigate to Pipeline tab
                              }
                            },
                            icon: const Icon(Icons.sync_alt, color: Color(0xFF2563EB), size: 18),
                            label: const Text(
                              'Review Pipeline',
                              style: TextStyle(color: Color(0xFF2563EB)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Recent Requests list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Restock Orders',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (onNavigateTab != null)
                        InkWell(
                          onTap: () => onNavigateTab!(1),
                          child: const Text(
                            'All Orders',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                ...roleRequests.take(4).map((req) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RequestDetailScreen(requestId: req.id),
                          ),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: req.priority == ReplenishmentPriority.urgentFastMoving
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          req.priority == ReplenishmentPriority.urgentFastMoving
                              ? Icons.bolt
                              : Icons.receipt_long,
                          color: req.priority == ReplenishmentPriority.urgentFastMoving
                              ? const Color(0xFFDC2626)
                              : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            req.id,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          StatusBadge(status: req.status, compact: true),
                        ],
                      ),
                      subtitle: Text(
                        '${req.storeName} • ${req.items.length} SKUs (${req.totalRequestedUnits} units)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                    ),
                  );
                }),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
