import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../models/replenishment_request.dart';
import '../services/inventory_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final GroceryItem? preselectedItem;
  final bool isEmergency;

  const CreateRequestScreen({
    super.key,
    this.preselectedItem,
    this.isEmergency = false,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final inventoryService = InventoryService();
  final Map<String, int> _selectedQuantities = {};
  late ReplenishmentPriority _priority;
  final TextEditingController _notesController = TextEditingController();
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  bool _fastMovingOnly = false;

  @override
  void initState() {
    super.initState();
    _priority = widget.isEmergency
        ? ReplenishmentPriority.urgentFastMoving
        : ReplenishmentPriority.standard;

    if (widget.preselectedItem != null) {
      _selectedQuantities[widget.preselectedItem!.id] =
          widget.preselectedItem!.reorderThreshold;
      if (widget.preselectedItem!.velocity == ItemVelocity.fastMoving) {
        _priority = ReplenishmentPriority.urgentFastMoving;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final catalog = inventoryService.catalog;
        final filteredItems = catalog.where((item) {
          if (_searchQuery.isNotEmpty &&
              !item.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !item.sku.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
          if (_selectedCategory != null && item.category != _selectedCategory) {
            return false;
          }
          if (_fastMovingOnly && item.velocity != ItemVelocity.fastMoving) {
            return false;
          }
          return true;
        }).toList();

        final totalSelectedUnits =
            _selectedQuantities.values.fold(0, (sum, q) => sum + q);

        return Scaffold(
          appBar: AppBar(
            title: const Text('New Replenishment Request'),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalSelectedUnits items selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Destination: ${inventoryService.currentStore.name}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: totalSelectedUnits > 0 ? _submitOrder : null,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _priority == ReplenishmentPriority.urgentFastMoving
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Mode / Urgency Selector Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Replenishment Urgency',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => setState(() => _priority = ReplenishmentPriority.urgentFastMoving),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _priority == ReplenishmentPriority.urgentFastMoving
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _priority == ReplenishmentPriority.urgentFastMoving
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFE5E7EB),
                                width: _priority == ReplenishmentPriority.urgentFastMoving ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _priority == ReplenishmentPriority.urgentFastMoving
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: _priority == ReplenishmentPriority.urgentFastMoving
                                      ? const Color(0xFFDC2626)
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.bolt, color: Color(0xFFDC2626), size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'Emergency Restock (Fast-Moving Item)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFDC2626),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Prioritized at top of warehouse dispatch queue to prevent stockouts.',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => setState(() => _priority = ReplenishmentPriority.standard),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _priority == ReplenishmentPriority.standard
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _priority == ReplenishmentPriority.standard
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE5E7EB),
                                width: _priority == ReplenishmentPriority.standard ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _priority == ReplenishmentPriority.standard
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: _priority == ReplenishmentPriority.standard
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Standard Replenishment Cycle',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Processed according to routine central warehouse schedule.',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Search & Filter controls
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or SKU...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fast-moving filter toggle chip
                Row(
                  children: [
                    FilterChip(
                      selected: _fastMovingOnly,
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 15, color: Color(0xFFDC2626)),
                          SizedBox(width: 4),
                          Text('Fast-Moving Only'),
                        ],
                      ),
                      onSelected: (selected) {
                        setState(() => _fastMovingOnly = selected);
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<ItemCategory?>(
                      value: _selectedCategory,
                      hint: const Text('Category'),
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Categories')),
                        ...ItemCategory.values.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Catalog List
                const Text(
                  'Select Items to Restock',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                ...filteredItems.map((item) {
                  final quantity = _selectedQuantities[item.id] ?? 0;
                  final isSelected = quantity > 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.grey[200]!,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: item.velocity == ItemVelocity.fastMoving
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  item.velocity == ItemVelocity.fastMoving
                                      ? Icons.bolt
                                      : Icons.inventory_2_outlined,
                                  color: item.velocity == ItemVelocity.fastMoving
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF4B5563),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (item.velocity == ItemVelocity.fastMoving) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '⚡ Fast-Turn',
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
                                      'Store Stock: ${item.storeStock} ${item.unit} • Warehouse: ${item.warehouseStock} available',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: item.isCriticalRisk
                                            ? const Color(0xFFDC2626)
                                            : Colors.grey[700],
                                        fontWeight: item.isCriticalRisk
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Adjuster
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: quantity > 0 ? Colors.red[600] : Colors.grey[400],
                                    onPressed: quantity > 0
                                        ? () {
                                            setState(() {
                                              if (quantity <= 5) {
                                                _selectedQuantities.remove(item.id);
                                              } else {
                                                _selectedQuantities[item.id] = quantity - 5;
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: const Color(0xFF2563EB),
                                    onPressed: () {
                                      setState(() {
                                        _selectedQuantities[item.id] = quantity + 5;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Order Notes
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Request Notes / Special Handling',
                    hintText: 'e.g. Needs expedited arrival before 5pm peak shopping rush...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitOrder() {
    final catalog = inventoryService.catalog;
    final items = <ReplenishmentItem>[];

    for (final entry in _selectedQuantities.entries) {
      if (entry.value <= 0) continue;
      final catalogItem = catalog.firstWhere((c) => c.id == entry.key);
      items.add(ReplenishmentItem.fromGroceryItem(catalogItem, entry.value));
    }

    if (items.isEmpty) return;

    final created = inventoryService.createRequest(
      items: items,
      priority: _priority,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Replenishment Request ${created.id} submitted to Central Warehouse!',
        ),
        backgroundColor: const Color(0xFF16A34A),
      ),
    );
  }
}
