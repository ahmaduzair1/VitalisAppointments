import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(
            'Alerts',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stay updated with your latest health activities.',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.xl),

          // ── Section label ──────────────────────────────
          Text(
            'TODAY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 1,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.md),

          // ── Alert cards ────────────────────────────────
          const AlertCard(
            icon: Icons.calendar_today_rounded,
            title: 'Appointment Reminder',
            description: 'Your session with Dr. Aris Thorne is scheduled for tomorrow at 10:30 AM.',
            isPrimary: true,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms),

          const AlertCard(
            icon: Icons.chat_bubble_rounded,
            title: 'New Message',
            description: '"The blood work results are in. Everything looks stable..."',
            isPrimary: false,
          ).animate(delay: 420.ms).fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}