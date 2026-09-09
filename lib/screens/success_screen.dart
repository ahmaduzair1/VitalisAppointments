import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/network_avatar.dart';
import 'auth_wrapper.dart';
import '../core/constants/page_transitions.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final String date;
  final String time;
  final bool paid;

  const SuccessScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    this.paid = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 28),
              Text(
                paid ? 'Booked and paid' : 'Visit reserved',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paid
                    ? 'The fee is marked paid in your hospital record.'
                    : 'Please pay at the clinic desk when you arrive.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 28),
              VitalisCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        NetworkAvatar(
                          url: '${doctor['image'] ?? ''}',
                          size: 48,
                          radius: 24,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${doctor['name']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface)),
                              Text('${doctor['specialty']}',
                                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRow(cs, Icons.calendar_today_rounded, 'Date', date),
                    const SizedBox(height: 12),
                    _buildRow(cs, Icons.access_time_rounded, 'Time', time),
                    const SizedBox(height: 12),
                    _buildRow(cs, Icons.payments_outlined, 'Payment',
                        paid ? 'Paid · ${Formatters.fee(doctor['fee'])}' : 'Pay at clinic'),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              VitalisButton(
                label: 'Back to home',
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  PageTransitions.fadeSlide(const AuthWrapper()),
                  (route) => false,
                ),
              ),
              const SizedBox(height: 12),
              VitalisButton(
                label: 'View my visits',
                variant: VitalisButtonVariant.secondary,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  PageTransitions.fadeSlide(const AuthWrapper()),
                  (route) => false,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
      ],
    );
  }
}
