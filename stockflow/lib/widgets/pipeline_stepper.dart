import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/replenishment_request.dart';

class PipelineStepper extends StatelessWidget {
  final ReplenishmentRequest request;

  const PipelineStepper({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final activeIndex = request.status.stepIndex;

    final steps = [
      _StepInfo(
        title: 'Requested',
        subtitle: dateFormat.format(request.createdAt),
        icon: Icons.edit_note,
        isCompleted: activeIndex >= 0,
        isCurrent: activeIndex == 0,
      ),
      _StepInfo(
        title: 'Approved',
        subtitle: request.approvedAt != null
            ? '${dateFormat.format(request.approvedAt!)}\nBy: ${request.approvedBy ?? "Warehouse"}'
            : 'Awaiting Warehouse',
        icon: Icons.check_circle_outline,
        isCompleted: activeIndex >= 1,
        isCurrent: activeIndex == 1,
      ),
      _StepInfo(
        title: 'Dispatched',
        subtitle: request.dispatchedAt != null
            ? '${dateFormat.format(request.dispatchedAt!)}\n${request.carrierName ?? "In Transit"}'
            : 'Awaiting Transit',
        icon: Icons.local_shipping_outlined,
        isCompleted: activeIndex >= 2,
        isCurrent: activeIndex == 2,
      ),
      _StepInfo(
        title: 'Received',
        subtitle: request.receivedAt != null
            ? '${dateFormat.format(request.receivedAt!)}\nStock Updated'
            : (request.estimatedDeliveryAt != null
                ? 'ETA: ${dateFormat.format(request.estimatedDeliveryAt!)}'
                : 'Pending Arrival'),
        icon: Icons.inventory_outlined,
        isCompleted: activeIndex >= 3,
        isCurrent: activeIndex == 3,
      ),
    ];

    if (request.status == ReplenishmentStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Request was cancelled: ${request.notes ?? "No reason specified"}',
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isEven) {
              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              return Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.isCompleted
                            ? (step.isCurrent ? const Color(0xFF2563EB) : const Color(0xFF16A34A))
                            : const Color(0xFFE5E7EB),
                        border: step.isCurrent
                            ? Border.all(color: const Color(0xFF93C5FD), width: 3)
                            : null,
                      ),
                      child: Icon(
                        step.isCompleted ? step.icon : Icons.circle,
                        size: step.isCompleted ? 16 : 8,
                        color: step.isCompleted ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: step.isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: step.isCompleted ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: step.isCurrent ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final leftStepIndex = (index - 1) ~/ 2;
              final isLineCompleted = activeIndex > leftStepIndex;
              return Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: 3,
                  color: isLineCompleted ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;

  _StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });
}
