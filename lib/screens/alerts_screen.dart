import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/page_transitions.dart';
import '../core/formatters.dart';
import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/notification_service.dart';
import '../widgets/vitalis_card.dart';
import 'appointment_detail_screen.dart';
import 'review_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.instance.watchMine(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (items.any((n) => !n.isRead))
                            TextButton(
                              onPressed: () =>
                                  NotificationService.instance.markAllRead(items),
                              child: const Text('Mark all read'),
                            ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Bookings, payments, reminders, and a note after your visit to rate the doctor.',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (snapshot.hasError)
                const SliverFillRemaining(
                  child: Center(child: Text('Could not load notifications.')),
                )
              else if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 56, color: cs.primary.withValues(alpha: 0.45)),
                        const SizedBox(height: 12),
                        Text('You are all caught up',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: cs.onSurface)),
                        const SizedBox(height: 6),
                        Text(
                          'When you book, pay, or a visit is coming up, a note will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _alert(context, items[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _alert(BuildContext ctx, AppNotification n) {
    final cs = Theme.of(ctx).colorScheme;
    final icon = switch (n.type) {
      'booking' => Icons.calendar_today_rounded,
      'payment' => Icons.payments_rounded,
      'cancel' => Icons.event_busy_rounded,
      'reminder' => Icons.notifications_active_rounded,
      'review' => Icons.rate_review_rounded,
      _ => Icons.notifications_rounded,
    };
    final color = switch (n.type) {
      'payment' => const Color(0xFF059669),
      'cancel' => cs.error,
      'booking' => cs.primary,
      'reminder' => const Color(0xFFD97706),
      'review' => const Color(0xFF7C3AED),
      _ => const Color(0xFF0EA5A4),
    };

    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () async {
        try {
          await NotificationService.instance.markRead(n.id);
          if (n.appointmentId.isEmpty || !ctx.mounted) return;
          final Appointment? apt =
              await AppointmentService.instance.getById(n.appointmentId);
          if (apt == null || !ctx.mounted) return;
          Navigator.push(
            ctx,
            PageTransitions.slideRight(
              n.type == 'review'
                  ? ReviewScreen(appointment: apt)
                  : AppointmentDetailScreen(appointment: apt),
            ),
          );
        } catch (e) {
          if (!ctx.mounted) return;
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Could not open this alert: $e')),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.body,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.relativeTime(n.createdAt),
                  style: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
