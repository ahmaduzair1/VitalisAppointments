import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_config.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/network_avatar.dart';
import '../services/auth_service.dart';
import 'medical_history_screen.dart';
import 'manage_visits_screen.dart';
import 'payment_methods_screen.dart';
import 'privacy_settings_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  Future<void> _handleLogout() async {
    try {
      await AuthService().signOut();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final admin = AppConfig.isAdminEmail(currentUser?.email);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                String userName = currentUser?.displayName ?? 'Guest';
                String photo = currentUser?.photoURL ?? '';
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['name'] ?? userName;
                  photo = (userData['photoUrl'] as String?)?.isNotEmpty == true
                      ? userData['photoUrl']
                      : photo;
                }
                final patientId = currentUser != null
                    ? '#${currentUser.uid.substring(0, 6).toUpperCase()}'
                    : '#------';

                return Column(
                  children: [
                    NetworkAvatar(
                      url: photo,
                      size: 96,
                      radius: 48,
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    Text(userName,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text(
                      admin ? 'Hospital admin' : 'Patient ID: $patientId',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                    ),
                    if (currentUser?.email != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(currentUser!.email!,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            VitalisCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.palette_rounded, color: cs.onSurfaceVariant),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Appearance',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: cs.onSurface, fontSize: 15)),
                      Text('Light / Dark mode',
                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                    ]),
                  ]),
                  const ThemeToggle(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            VitalisCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _tile(
                    context,
                    Icons.event_repeat_rounded,
                    'Manage visits',
                    'Reschedule the date or cancel an upcoming appointment',
                    () => Navigator.push(
                        context, PageTransitions.slideRight(const ManageVisitsScreen()))),
                Divider(height: 1, indent: 64, color: cs.outline.withValues(alpha: 0.3)),
                _tile(
                    context,
                    Icons.medical_information_rounded,
                    'Health notes',
                    'Allergies and conditions your doctors should know',
                    () => Navigator.push(
                        context, PageTransitions.slideRight(const MedicalHistoryScreen()))),
                Divider(height: 1, indent: 64, color: cs.outline.withValues(alpha: 0.3)),
                _tile(
                    context,
                    Icons.payment_rounded,
                    'How you pay',
                    'Pay at the clinic or pay when you book',
                    () => Navigator.push(
                        context, PageTransitions.slideRight(const PaymentMethodsScreen()))),
                Divider(height: 1, indent: 64, color: cs.outline.withValues(alpha: 0.3)),
                _tile(
                    context,
                    Icons.notifications_active_rounded,
                    'Notifications & privacy',
                    'Day-before and same-day visit reminders',
                    () => Navigator.push(
                        context, PageTransitions.slideRight(const PrivacySettingsScreen()))),
              ]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: _handleLogout,
                icon: Icon(Icons.logout_rounded, color: cs.error),
                label: Text('Logout',
                    style: TextStyle(color: cs.error, fontSize: 16, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                    backgroundColor: cs.error.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: cs.onSurface.withValues(alpha: 0.06),
            child: Icon(icon, color: cs.onSurfaceVariant, size: 20),
          ),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface, fontSize: 15)),
          subtitle: Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
