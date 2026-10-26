import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class StockIndicator extends StatelessWidget {
  final GroceryItem item;

  const StockIndicator({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = item.reorderThreshold > 0
        ? (item.storeStock / item.reorderThreshold).clamp(0.0, 2.0)
        : 1.0;

    Color color;
    String statusLabel;
    if (item.storeStock <= 0) {
      color = const Color(0xFFDC2626);
      statusLabel = 'OUT OF STOCK';
    } else if (item.isCriticalRisk) {
      color = const Color(0xFFDC2626);
      statusLabel = 'CRITICAL (< ${item.hoursUntilStockout.toStringAsFixed(1)}h left)';
    } else if (item.isLowStock) {
      color = const Color(0xFFD97706);
      statusLabel = 'LOW STOCK';
    } else {
      color = const Color(0xFF16A34A);
      statusLabel = 'HEALTHY';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${item.storeStock} ${item.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  ' in store',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (ratio / 2.0).clamp(0.05, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Safe Threshold: ${item.reorderThreshold} ${item.unit}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Central Warehouse: ${item.warehouseStock}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
