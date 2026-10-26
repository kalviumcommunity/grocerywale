import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../models/store_info.dart';
import '../services/inventory_service.dart';
import '../widgets/stock_indicator.dart';
import 'create_request_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final inventoryService = InventoryService();
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  bool _fastMovingOnly = false;
  bool _lowStockOnly = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: inventoryService,
      builder: (context, _) {
        final catalog = inventoryService.catalog;
        final currentStore = inventoryService.currentStore;
        final isStoreRole = inventoryService.currentRole == UserRole.storeManager;

        final items = catalog.where((item) {
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
          if (_lowStockOnly && !item.isLowStock) {
            return false;
          }
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory & Velocity Monitor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  isStoreRole
                      ? 'Local Stock for ${currentStore.name}'
                      : 'Central Warehouse & Store Cross-Stock View',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search & Filter header
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search items or SKU...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            selected: _fastMovingOnly,
                            avatar: const Icon(Icons.bolt, size: 14, color: Color(0xFFDC2626)),
                            label: const Text('Fast-Moving'),
                            onSelected: (val) => setState(() => _fastMovingOnly = val),
                          ),
                          const SizedBox(width: 6),
                          FilterChip(
                            selected: _lowStockOnly,
                            avatar: const Icon(Icons.warning_amber, size: 14, color: Color(0xFFD97706)),
                            label: const Text('Low Stock Risk'),
                            onSelected: (val) => setState(() => _lowStockOnly = val),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<ItemCategory?>(
                            value: _selectedCategory,
                            hint: const Text('All Categories', style: TextStyle(fontSize: 13)),
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
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Items List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No products match your criteria',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: item.isCriticalRisk
                                    ? const Color(0xFFFCA5A5)
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                if (item.velocity == ItemVelocity.fastMoving) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFEF3C7),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.bolt, size: 11, color: Color(0xFFB45309)),
                                                        Text(
                                                          'Fast-Turn',
                                                          style: TextStyle(
                                                            fontSize: 9,
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
                                            const SizedBox(height: 2),
                                            Text(
                                              'SKU: ${item.sku} • Category: ${item.category.displayName} • \$${item.unitPrice.toStringAsFixed(2)} / ${item.unit}',
                                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isStoreRole)
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => CreateRequestScreen(
                                                  preselectedItem: item,
                                                  isEmergency: item.isCriticalRisk || item.isLowStock,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                                          label: const Text('Restock'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: item.isCriticalRisk
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF2563EB),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  StockIndicator(item: item),

                                  if (item.velocity == ItemVelocity.fastMoving) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.speed, size: 14, color: Color(0xFFD97706)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Daily Consumption: ~${item.dailyBurnRate.toStringAsFixed(0)} ${item.unit}/day • Runout Time: ${item.hoursUntilStockout.toStringAsFixed(1)}h',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFB45309),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
