import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/replenishment_request.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> with SingleTickerProviderStateMixin {
  final inventoryService = InventoryService();
  late TabController _tabController;
  bool _fastMovingOnly = false;

  final List<ReplenishmentStatus?> _statusTabs = [
    null,
    ReplenishmentStatus.requested,
    ReplenishmentStatus.approved,
    ReplenishmentStatus.dispatched,
    ReplenishmentStatus.received,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final currentRole = inventoryService.currentRole;
        final isStoreManager = currentRole == UserRole.storeManager;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Replenishment Pipeline',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  isStoreManager
                      ? 'Live Pipeline • ${inventoryService.currentStore.name}'
                      : 'Central Warehouse Chain-wide Restock Queue',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _fastMovingOnly ? Icons.bolt : Icons.filter_alt_outlined,
                  color: _fastMovingOnly ? const Color(0xFFDC2626) : null,
                ),
                tooltip: _fastMovingOnly ? 'Showing Fast-Moving Only' : 'Filter Fast-Moving',
                onPressed: () {
                  setState(() => _fastMovingOnly = !_fastMovingOnly);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF2563EB),
              tabs: const [
                Tab(text: 'All Stages'),
                Tab(text: 'Requested'),
                Tab(text: 'Approved'),
                Tab(text: 'Dispatched'),
                Tab(text: 'Received'),
              ],
            ),
          ),
          floatingActionButton: isStoreManager
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateRequestScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF2563EB),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('New Restock', style: TextStyle(color: Colors.white)),
                )
              : null,
          body: TabBarView(
            controller: _tabController,
            children: _statusTabs.map((statusFilter) {
              final requests = inventoryService.getRequestsForRole(
                statusFilter: statusFilter,
                onlyCurrentStore: isStoreManager,
                fastMovingOnly: _fastMovingOnly,
              );

              if (requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No requests in ${statusFilter?.displayName ?? "this tab"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fastMovingOnly
                            ? 'Try turning off the fast-moving filter.'
                            : 'All stores are synchronized.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return _buildRequestCard(req, isStoreManager);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(ReplenishmentRequest req, bool isStoreManager) {
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: req.priority == ReplenishmentPriority.urgentFastMoving
              ? const Color(0xFFF87171)
              : Colors.grey[200]!,
          width: req.priority == ReplenishmentPriority.urgentFastMoving ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RequestDetailScreen(requestId: req.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: ID, Store, Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        req.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${req.storeName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  StatusBadge(status: req.status, compact: true),
                ],
              ),

              const SizedBox(height: 8),

              // Priority & Fast-Moving badges
              Row(
                children: [
                  PriorityBadge(priority: req.priority),
                  if (req.containsFastMoving) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, size: 12, color: Color(0xFFB45309)),
                          SizedBox(width: 2),
                          Text(
                            'High-Demand SKUs',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Item Preview Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: req.items.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '${item.requestedQuantity}x ${item.itemName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Bottom status bar & Quick Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        req.status == ReplenishmentStatus.dispatched && req.estimatedDeliveryAt != null
                            ? 'ETA: ${dateFormat.format(req.estimatedDeliveryAt!)}'
                            : 'Submitted: ${dateFormat.format(req.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: req.status == ReplenishmentStatus.dispatched
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: req.status == ReplenishmentStatus.dispatched
                              ? const Color(0xFF0369A1)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Quick Action button depending on status & role
                  if (isStoreManager && req.status == ReplenishmentStatus.dispatched)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        inventoryService.markReceived(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${req.id} marked as Received & restocked!'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Confirm Received', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  else if (!isStoreManager && req.status == ReplenishmentStatus.requested)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        inventoryService.approveRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${req.id} approved!'),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  else
                    const Row(
                      children: [
                        Text('Details', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                        Icon(Icons.chevron_right, size: 16, color: Color(0xFF2563EB)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
