import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/theme_toggle.dart';
import 'login_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            // ── Avatar ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary.withAlpha(51), width: 3),
                boxShadow: [
                  BoxShadow(color: colors.primary.withAlpha(38), blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=44'),
                backgroundColor: colors.inputFill,
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sarah Jenkins',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              'Patient ID: #VT-99204',
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.xl),

            // ── Appearance toggle ────────────────────────
            VitalisCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.primary.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.palette_rounded, color: colors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Light / Dark mode', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const ThemeToggle(),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.md),

            // ── Settings list ────────────────────────────
            VitalisCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(context, Icons.medical_information_rounded, 'Medical History', 'Records, labs, and immunizations'),
                  Divider(height: 1, indent: 60, color: colors.divider.withAlpha(77)),
                  _buildListTile(context, Icons.payment_rounded, 'Payment Methods', 'Manage billing and insurance'),
                  Divider(height: 1, indent: 60, color: colors.divider.withAlpha(77)),
                  _buildListTile(context, Icons.privacy_tip_rounded, 'Privacy Settings', 'Data sharing and HIPAA consent'),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            const SizedBox(height: AppSpacing.xl),

            // ── Logout button ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  PageTransitions.fade(const LoginScreen()),
                ),
                icon: Icon(Icons.logout_rounded, color: colors.error),
                label: Text(
                  'Logout',
                  style: TextStyle(color: colors.error, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: colors.error.withAlpha(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                ),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle) {
    final colors = AppColors.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.primary.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: colors.textPrimary, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
    );
  }
}