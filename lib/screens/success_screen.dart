import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import 'main_tab_navigator.dart';
import '../core/constants/page_transitions.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String date;
  final String time;

  const SuccessScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated checkmark ──────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981),
                      const Color(0xFF10B981).withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // ── Title ───────────────────────────────────
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 8),

              Text(
                'Your appointment has been scheduled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 32),

              // ── Appointment details card ────────────────
              VitalisCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Doctor
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(doctor['image']),
                          backgroundColor: cs.onSurfaceVariant.withOpacity(0.08),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor['specialty'],
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: cs.outline.withOpacity(0.5)),
                    ),

                    _buildRow(cs, Icons.calendar_today_rounded, 'Date', date),
                    const SizedBox(height: 12),
                    _buildRow(cs, Icons.access_time_rounded, 'Time', time),
                    const SizedBox(height: 12),
                    _buildRow(cs, Icons.location_on_outlined, 'Location',
                        doctor['location']),
                  ],
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),

              const Spacer(flex: 3),

              // ── CTAs ────────────────────────────────────
              VitalisButton(
                label: 'Back to Home',
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  PageTransitions.fadeSlide(const MainTabNavigator()),
                  (route) => false,
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              VitalisButton(
                label: 'View My Appointments',
                variant: VitalisButtonVariant.secondary,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  PageTransitions.fadeSlide(const MainTabNavigator()),
                  (route) => false,
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
      ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
