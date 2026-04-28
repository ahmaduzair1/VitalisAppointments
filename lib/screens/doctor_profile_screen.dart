import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/stat_card.dart';
import '../widgets/vitalis_button.dart';
import 'book_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image with gradient overlay ─────────
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(doctor['image']), fit: BoxFit.cover),
                  ),
                ),
                // Gradient overlay for text readability
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, colors.background.withAlpha(230)],
                    ),
                  ),
                ),
              ],
            ),
            // ── Doctor info ──────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.success,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: const Text('VERIFIED PROFESSIONAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0, duration: 400.ms),
                  const SizedBox(height: 14),
                  Text(doctor['name'], style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary))
                      .animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(doctor['specialty'], style: TextStyle(fontSize: 16, color: colors.primary, fontWeight: FontWeight.w500))
                      .animate(delay: 150.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Stat cards ─────────────────────────
                  Row(
                    children: [
                      StatCard(icon: Icons.star_rounded, value: doctor['rating'].toString(), label: '${doctor['reviews']} Reviews'),
                      const SizedBox(width: AppSpacing.sm + 4),
                      StatCard(icon: Icons.workspace_premium_rounded, value: doctor['experience'].split(' ')[0], label: 'Experience'),
                      const SizedBox(width: AppSpacing.sm + 4),
                      StatCard(icon: Icons.people_rounded, value: doctor['patients'], label: 'Patients'),
                    ],
                  ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
                  const SizedBox(height: AppSpacing.lg),

                  // ── About section ──────────────────────
                  Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                  const SizedBox(height: 12),
                  Text(
                    '${doctor['name']} is a board-certified specialist focusing on preventive care and lifestyle-based interventions. Known for a patient-first approach.',
                    style: TextStyle(color: colors.textSecondary, height: 1.6, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── Bottom CTA bar ─────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.divider.withAlpha(77), width: 0.5)),
        ),
        child: SafeArea(
          child: VitalisButton(
            label: 'Book Appointment →',
            onPressed: () => Navigator.push(context, PageTransitions.slideRight(BookAppointmentScreen(doctor: doctor))),
          ),
        ),
      ),
    );
  }
}