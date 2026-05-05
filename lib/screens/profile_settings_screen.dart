import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/theme_toggle.dart';
import 'login_screen.dart';
import 'medical_history_screen.dart';
import 'payment_methods_screen.dart';
import 'privacy_settings_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            // ── Avatar ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.outline.withOpacity(0.5), width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                    blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: CircleAvatar(radius: 48,
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=44'),
                  backgroundColor: cs.onSurfaceVariant.withOpacity(0.08)),
            ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
                duration: 500.ms, curve: Curves.easeOutBack).fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            Text('Sarah Jenkins', style: TextStyle(fontSize: 24,
                fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.5))
                .animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text('Patient ID: #VT-99204', style: TextStyle(
                color: cs.onSurfaceVariant, fontSize: 14))
                .animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),

            // ── Appearance ─────────────────────────────
            VitalisCard(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.06),
                          shape: BoxShape.circle),
                      child: Icon(Icons.palette_rounded, color: cs.onSurfaceVariant, size: 20)),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700,
                        color: cs.onSurface, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Light / Dark mode', style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12)),
                  ]),
                ]),
                const ThemeToggle(),
              ],
            )).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 12),

            // ── Settings list ──────────────────────────
            VitalisCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _tile(context, Icons.medical_information_rounded,
                    'Medical History', 'Records, labs, and immunizations',
                    () => Navigator.push(context,
                        PageTransitions.slideRight(const MedicalHistoryScreen()))),
                Divider(height: 1, indent: 64, color: cs.outline.withOpacity(0.3)),
                _tile(context, Icons.payment_rounded,
                    'Payment Methods', 'Manage billing and insurance',
                    () => Navigator.push(context,
                        PageTransitions.slideRight(const PaymentMethodsScreen()))),
                Divider(height: 1, indent: 64, color: cs.outline.withOpacity(0.3)),
                _tile(context, Icons.privacy_tip_rounded,
                    'Privacy Settings', 'Data sharing and HIPAA consent',
                    () => Navigator.push(context,
                        PageTransitions.slideRight(const PrivacySettingsScreen()))),
              ]),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),

            // ── Logout ─────────────────────────────────
            SizedBox(width: double.infinity, height: 56,
              child: TextButton.icon(
                onPressed: () => Navigator.pushReplacement(context,
                    PageTransitions.fade(const LoginScreen())),
                icon: Icon(Icons.logout_rounded, color: cs.error),
                label: Text('Logout', style: TextStyle(color: cs.error,
                    fontSize: 16, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  backgroundColor: cs.error.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return Material(color: Colors.transparent,
      child: InkWell(onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cs.onSurface.withOpacity(0.06),
                  shape: BoxShape.circle),
              child: Icon(icon, color: cs.onSurfaceVariant, size: 20)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700,
              color: cs.onSurface, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(
              color: cs.onSurfaceVariant, fontSize: 12)),
          trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}