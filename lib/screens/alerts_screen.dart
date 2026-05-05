import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/vitalis_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Text('Notifications',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.5))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text('Stay updated with your health activities.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15))
              .animate(delay: 100.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          Text('TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _alert(context, Icons.calendar_today_rounded, cs.primary,
              'Appointment Reminder',
              'Your session with Dr. Julian Sterling is tomorrow at 10:00 AM.',
              '2 hours ago', true)
              .animate(delay: 200.ms).fadeIn(duration: 400.ms),
          _alert(context, Icons.chat_bubble_rounded, const Color(0xFF10B981),
              'New Message',
              '"Your blood work results are in. Everything looks stable..."',
              '4 hours ago', true)
              .animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Text('EARLIER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _alert(context, Icons.check_circle_rounded, const Color(0xFF10B981),
              'Appointment Completed',
              'Your session with Dr. Marcus Chen has been completed.',
              '2 days ago', false)
              .animate(delay: 400.ms).fadeIn(duration: 400.ms),
          _alert(context, Icons.local_offer_rounded, const Color(0xFFF59E0B),
              'Special Offer',
              'Get 20% off on your next dental check-up. Book now!',
              '3 days ago', false)
              .animate(delay: 500.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _alert(BuildContext ctx, IconData icon, Color color,
      String title, String desc, String time, bool unread) {
    final cs = Theme.of(ctx).colorScheme;
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(title),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: TextStyle(
                fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15, color: cs.onSurface))),
            if (unread) Container(width: 8, height: 8,
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: cs.onSurfaceVariant,
              fontSize: 13, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(time, style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.7), fontSize: 12)),
        ])),
      ]),
    );
  }
}