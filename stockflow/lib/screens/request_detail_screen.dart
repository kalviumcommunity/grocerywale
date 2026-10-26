import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/replenishment_request.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/pipeline_stepper.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final inventoryService = InventoryService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final request = inventoryService.getRequestById(widget.requestId);
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Request Details')),
            body: const Center(child: Text('Request not found')),
          );
        }

        final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
        final isWarehouseRole = inventoryService.currentRole == UserRole.warehouseManager;
        final isStoreRole = inventoryService.currentRole == UserRole.storeManager;

        return Scaffold(
          appBar: AppBar(
            title: Text(request.id),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: StatusBadge(status: request.status)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Info Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                  request.storeName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Submitted: ${dateFormat.format(request.createdAt)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            PriorityBadge(priority: request.priority),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text(
                          'Shared Replenishment Pipeline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PipelineStepper(request: request),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logistics & Tracking (if approved / dispatched)
                if (request.status == ReplenishmentStatus.dispatched ||
                    request.status == ReplenishmentStatus.received) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_shipping, color: Color(0xFF0284C7), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Dispatch & Logistics Details',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Carrier / Vehicle', request.carrierName ?? 'Central Logistics'),
                          _buildDetailRow('Tracking Reference', request.trackingReference ?? 'N/A'),
                          if (request.dispatchedAt != null)
                            _buildDetailRow('Dispatched Time', dateFormat.format(request.dispatchedAt!)),
                          if (request.estimatedDeliveryAt != null)
                            _buildDetailRow(
                              'Estimated Arrival',
                              dateFormat.format(request.estimatedDeliveryAt!),
                              isHighlighted: true,
                            ),
                          if (request.receivedAt != null) ...[
                            _buildDetailRow('Received Time', dateFormat.format(request.receivedAt!)),
                            _buildDetailRow('Received By', request.receivedBy ?? 'Store Team'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes Card
                if (request.notes != null && request.notes!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Store Manager Notes:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.notes!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Items Table
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Requested Items (${request.items.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Est. Total: \$${request.estimatedTotalValue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        ...request.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: item.isFastMoving
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    item.isFastMoving ? Icons.bolt : Icons.inventory_2_outlined,
                                    color: item.isFastMoving
                                        ? const Color(0xFFD97706)
                                        : const Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item.itemName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (item.isFastMoving) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'FAST TURN',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFDC2626),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'SKU: ${item.sku} • \$${item.unitPrice.toStringAsFixed(2)} / ${item.unit}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.requestedQuantity} ${item.unit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (request.status != ReplenishmentStatus.requested)
                                      Text(
                                        'Approved: ${item.approvedQuantity}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF059669),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (request.status == ReplenishmentStatus.received)
                                      Text(
                                        'Restocked: ${item.receivedQuantity}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons by Role
                if (isWarehouseRole && request.status == ReplenishmentStatus.requested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(context, request),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Replenishment & Allocate Stock'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                if (isWarehouseRole && request.status == ReplenishmentStatus.approved)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showDispatchDialog(context, request),
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('Dispatch Order from Central Warehouse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                if (isStoreRole && request.status == ReplenishmentStatus.dispatched)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        inventoryService.markReceived(request.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Delivery confirmed for ${request.id}! Store shelves restocked.',
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_box_outlined),
                      label: const Text('Confirm Delivery & Restock Store Shelves'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? const Color(0xFF0284C7) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, ReplenishmentRequest request) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Approve Restock Request'),
          content: Text(
            'Approve ${request.totalRequestedUnits} units for ${request.storeName}? Warehouse inventory will be allocated.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                inventoryService.approveRequest(
                  request.id,
                  approvedBy: 'Central Warehouse Supervisor',
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request ${request.id} approved! Ready for packing & dispatch.'),
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                );
              },
              child: const Text('Confirm Approval'),
            ),
          ],
        );
      },
    );
  }

  void _showDispatchDialog(BuildContext context, ReplenishmentRequest request) {
    final carrierController = TextEditingController(text: 'FastDelivery Reefer #08');
    final trackingController = TextEditingController(text: 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Dispatch Shipment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: carrierController,
                decoration: const InputDecoration(
                  labelText: 'Carrier / Logistics Fleet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: trackingController,
                decoration: const InputDecoration(
                  labelText: 'Waybill / Tracking Ref',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                inventoryService.dispatchRequest(
                  request.id,
                  carrierName: carrierController.text,
                  trackingReference: trackingController.text,
                  estimatedDeliveryAt: DateTime.now().add(const Duration(hours: 2)),
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Shipment for ${request.id} marked as In Transit!'),
                    backgroundColor: const Color(0xFF0284C7),
                  ),
                );
              },
              child: const Text('Mark Dispatched'),
            ),
          ],
        );
      },
    );
  }
}
