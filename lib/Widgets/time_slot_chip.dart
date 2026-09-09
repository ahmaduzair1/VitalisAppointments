import 'package:flutter/material.dart';

/// Selectable time slot chip with animated state.
class TimeSlotChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isDisabled;
  final bool isTaken;
  final VoidCallback? onTap;

  const TimeSlotChip({
    super.key,
    required this.time,
    this.isSelected = false,
    this.isDisabled = false,
    this.isTaken = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? cs.onSurfaceVariant.withValues(alpha: 0.05)
              : isSelected
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? cs.outline.withValues(alpha: 0.2)
                : isSelected
                    ? cs.primary
                    : cs.outline,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                    : isSelected
                        ? cs.onPrimary
                        : cs.onSurface,
              ),
            ),
            if (isTaken) ...[
              const SizedBox(height: 2),
              Text(
                'Booked',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
