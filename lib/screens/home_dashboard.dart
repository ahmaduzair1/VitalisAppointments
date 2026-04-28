import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/page_transitions.dart';
import '../core/mock_data.dart';
import '../widgets/section_header.dart';
import '../widgets/category_chip.dart';
import '../widgets/doctor_card.dart';
import 'doctor_listings_screen.dart';
import 'doctor_profile_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.primary.withAlpha(26),
                      child: Icon(Icons.person_rounded, color: colors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Vitalis', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.divider.withAlpha(77), width: 0.5),
                  ),
                  child: Icon(Icons.search_rounded, size: 22, color: colors.textPrimary),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Search bar ───────────────────────────────
            TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, clinics, or specialties',
                prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                filled: true,
                fillColor: colors.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull), borderSide: BorderSide.none),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Categories ──────────────────────────────
            const SectionHeader(title: 'Categories', actionText: 'See All'),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(icon: Icons.medical_services_rounded, label: 'General', isSelected: true),
                  CategoryChip(icon: Icons.clean_hands_rounded, label: 'Dentist'),
                  CategoryChip(icon: Icons.favorite_rounded, label: 'Cardiology'),
                  CategoryChip(icon: Icons.psychology_rounded, label: 'Psychiatry'),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Upcoming Appointment ────────────────────
            Text('Upcoming Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.primaryVariant],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(color: colors.primary.withAlpha(64), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tomorrow, 10:00 AM', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: colors.success, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                        child: const Text('CONFIRMED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Dr. Julianne Moore', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text('Heart Center, Block B', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.lg),

            // ── Featured Doctors ─────────────────────────
            SectionHeader(
              title: 'Featured Doctors',
              actionText: 'View all',
              onAction: () => Navigator.push(context, PageTransitions.slideRight(const DoctorListingsScreen())),
            ),
            const SizedBox(height: AppSpacing.md),
            ...MockData.doctors.take(2).map((doc) => DoctorCard(
              doctor: doc,
              onTap: () => Navigator.push(context, PageTransitions.slideRight(DoctorProfileScreen(doctor: doc))),
            )),
          ],
        ),
      ),
    );
  }
}