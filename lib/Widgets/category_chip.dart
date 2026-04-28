import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';

/// Category selection chip used on the home dashboard.
class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({super.key, required this.icon, required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary.withAlpha(26) : colors.inputFill,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: isSelected ? Border.all(color: colors.primary.withAlpha(77), width: 1.5) : null,
              ),
              child: Icon(icon, color: isSelected ? colors.primary : colors.textSecondary, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? colors.primary : colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
