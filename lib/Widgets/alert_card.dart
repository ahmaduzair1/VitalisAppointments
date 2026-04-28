import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'vitalis_card.dart';

/// Reusable alert notification card.
class AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isPrimary;

  const AlertCard({super.key, required this.icon, required this.title, required this.description, this.isPrimary = true});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accentColor = isPrimary ? colors.primary : colors.success;

    return VitalisCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      border: Border(left: BorderSide(color: accentColor, width: 4)),
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: accentColor.withAlpha(26), shape: BoxShape.circle),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: colors.textSecondary, height: 1.4, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
