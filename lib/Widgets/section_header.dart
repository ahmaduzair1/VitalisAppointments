import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable "Title — Action" row header used across screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionText!, style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
      ],
    );
  }
}
