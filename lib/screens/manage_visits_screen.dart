import 'package:flutter/material.dart';

import '../core/constants/page_transitions.dart';
import '../core/formatters.dart';
import '../core/schedule.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import 'appointment_detail_screen.dart';
import 'reschedule_screen.dart';

class ManageVisitsScreen extends StatelessWidget {
  const ManageVisitsScreen({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep visit', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(action, style: TextStyle(color: cs.error, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _cancel(BuildContext context, Appointment apt) async {
    final ok = await _confirm(
      context,
      title: 'Cancel this visit?',
      body:
          'This will cancel your appointment with ${apt.doctorName} on ${apt.date} at ${apt.time}. You can book again from Home.',
      action: 'Cancel visit',
    );
    if (!ok) return;
    try {
      await AppointmentService.instance.cancel(apt);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visit cancelled')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Manage visits')),
      body: StreamBuilder<List<Appointment>>(
        stream: AppointmentService.instance.watchMine(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final upcoming = (snapshot.data ?? []).where((a) => a.isUpcoming).toList();
          if (upcoming.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 52, color: cs.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No upcoming visits',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18, color: cs.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'When you book a doctor, you can reschedule or cancel it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Text(
                    'Change the date or cancel before your visit. Reminders are sent the day before and on the day of the appointment.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList.builder(
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final apt = upcoming[index];
                    final proximity = VisitSchedule.proximity(apt.date, apt.time);
                    final badge = switch (proximity) {
                      VisitProximity.today => 'Today',
                      VisitProximity.tomorrow => 'Tomorrow',
                      _ => apt.date,
                    };
                    return VitalisCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(
                            AppointmentDetailScreen(appointment: apt)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(apt.doctorName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17,
                                            color: cs.onSurface)),
                                    const SizedBox(height: 4),
                                    Text(apt.doctorSpecialty,
                                        style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badge,
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${apt.date} · ${apt.time}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, color: cs.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${apt.location} · ${Formatters.fee(apt.fee)}',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: VitalisButton(
                                  label: 'Reschedule',
                                  height: 48,
                                  onPressed: () => Navigator.push(
                                    context,
                                    PageTransitions.slideRight(
                                        RescheduleScreen(appointment: apt)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: VitalisButton(
                                  label: 'Cancel',
                                  variant: VitalisButtonVariant.secondary,
                                  height: 48,
                                  onPressed: () => _cancel(context, apt),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
