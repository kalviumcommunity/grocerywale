import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/replenishment_request.dart';
import '../services/inventory_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import 'request_detail_screen.dart';

class WarehouseConsoleScreen extends StatefulWidget {
  const WarehouseConsoleScreen({super.key});

  @override
  State<WarehouseConsoleScreen> createState() => _WarehouseConsoleScreenState();
}

class _WarehouseConsoleScreenState extends State<WarehouseConsoleScreen> {
  final inventoryService = InventoryService();
  String? _selectedStoreFilter;
  ReplenishmentStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final stores = inventoryService.stores;
        final allRequests = inventoryService.requests;

        // Apply filters
        var filtered = allRequests.where((r) {
          if (_selectedStoreFilter != null && r.storeId != _selectedStoreFilter) {
            return false;
          }
          if (_statusFilter != null && r.status != _statusFilter) {
            return false;
          }
          return true;
        }).toList();

        // Sort: Urgent Fast-Moving first, then requested, then approved, then latest
        filtered.sort((a, b) {
          if (a.priority == ReplenishmentPriority.urgentFastMoving &&
              b.priority != ReplenishmentPriority.urgentFastMoving) {
            return -1;
          }
          if (b.priority == ReplenishmentPriority.urgentFastMoving &&
              a.priority != ReplenishmentPriority.urgentFastMoving) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });

        final pendingApprovalCount =
            allRequests.where((r) => r.status == ReplenishmentStatus.requested).length;
        final pendingDispatchCount =
            allRequests.where((r) => r.status == ReplenishmentStatus.approved).length;
        final urgentCount = allRequests
            .where((r) =>
                r.priority == ReplenishmentPriority.urgentFastMoving &&
                r.status != ReplenishmentStatus.received &&
                r.status != ReplenishmentStatus.cancelled)
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central Warehouse Dispatch',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Chain Fulfillment & Allocation Hub',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Urgent Restocks',
                        count: urgentCount.toString(),
                        color: const Color(0xFFDC2626),
                        icon: Icons.bolt,
                        subtitle: 'Fast-turn risk',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Needs Approval',
                        count: pendingApprovalCount.toString(),
                        color: const Color(0xFFD97706),
                        icon: Icons.pending_actions,
                        subtitle: 'Awaiting stock check',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Ready to Ship',
                        count: pendingDispatchCount.toString(),
                        color: const Color(0xFF2563EB),
                        icon: Icons.local_shipping,
                        subtitle: 'Allocated in warehouse',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Filters bar
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String?>(
                            value: _selectedStoreFilter,
                            hint: const Text('All Grocery Stores'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Grocery Stores')),
                              ...stores.map(
                                (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                              ),
                            ],
                            onChanged: (val) => setState(() => _selectedStoreFilter = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<ReplenishmentStatus?>(
                          value: _statusFilter,
                          hint: const Text('All Statuses'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Statuses')),
                            ...ReplenishmentStatus.values.map(
                              (st) => DropdownMenuItem(value: st, child: Text(st.displayName)),
                            ),
                          ],
                          onChanged: (val) => setState(() => _statusFilter = val),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Store Replenishment Queue (${filtered.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Sorted by Fast-Moving Urgency',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (filtered.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No replenishment requests match the selected filters.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...filtered.map((req) => _buildWarehouseRequestTile(req)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseRequestTile(ReplenishmentRequest req) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: req.priority == ReplenishmentPriority.urgentFastMoving
              ? const Color(0xFFEF4444)
              : Colors.grey[200]!,
          width: req.priority == ReplenishmentPriority.urgentFastMoving ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${req.storeName} (${req.id})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      dateFormat.format(req.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                StatusBadge(status: req.status, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PriorityBadge(priority: req.priority),
                const SizedBox(width: 8),
                Text(
                  '${req.items.length} SKUs • ${req.totalRequestedUnits} units total',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Items summary
            ...req.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      item.isFastMoving ? Icons.bolt : Icons.arrow_right,
                      size: 14,
                      color: item.isFastMoving ? const Color(0xFFDC2626) : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${item.itemName} (${item.sku})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: item.isFastMoving ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '${item.requestedQuantity} ${item.unit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RequestDetailScreen(requestId: req.id),
                      ),
                    );
                  },
                  child: const Text('View Full Order'),
                ),
                const SizedBox(width: 8),
                if (req.status == ReplenishmentStatus.requested)
                  ElevatedButton.icon(
                    onPressed: () {
                      inventoryService.approveRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order ${req.id} approved and stock reserved!'),
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve & Reserve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (req.status == ReplenishmentStatus.approved)
                  ElevatedButton.icon(
                    onPressed: () {
                      inventoryService.dispatchRequest(
                        req.id,
                        carrierName: 'Central Express Fleet #02',
                        trackingReference: 'TRK-${req.id.replaceAll("REQ-", "")}',
                        estimatedDeliveryAt: DateTime.now().add(const Duration(hours: 2)),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order ${req.id} dispatched from Warehouse!'),
                          backgroundColor: const Color(0xFF0284C7),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_shipping, size: 16),
                    label: const Text('Dispatch Shipment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
