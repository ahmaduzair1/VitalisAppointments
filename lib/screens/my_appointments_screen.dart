import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../widgets/appointment_card.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Appointments',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Manage your health journey and upcoming visits.',
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Tab selector ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        boxShadow: [
                          BoxShadow(color: colors.textPrimary.withAlpha(13), blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        'Upcoming',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Text(
                        'Past',
                        style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Appointment list ─────────────────────────
            Expanded(
              child: ListView(
                children: [
                  AppointmentCard(
                    name: 'Dr. Julian Vane',
                    specialty: 'Cardiologist',
                    date: 'Oct 24, 2023',
                    time: '09:30 AM',
                    status: 'CONFIRMED',
                    statusColor: colors.success,
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms),
                  AppointmentCard(
                    name: 'Dr. Sarah Jenkins',
                    specialty: 'Dermatologist',
                    date: 'Oct 28, 2023',
                    time: '02:15 PM',
                    status: 'PENDING',
                    statusColor: colors.info,
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}