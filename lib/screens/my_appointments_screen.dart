import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/constants/page_transitions.dart';
import '../core/formatters.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/network_avatar.dart';
import '../widgets/vitalis_card.dart';
import 'appointment_detail_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My visits',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -1.0,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Upcoming bookings, payment status, and past visits.',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTab('Upcoming', 0),
                  _buildTab('Past', 1),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: AppointmentService.instance.watchMine(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Could not load visits. Pull back and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final items = all.where((apt) {
                  if (_selectedTabIndex == 0) return apt.status == 'upcoming';
                  return apt.status == 'completed' || apt.status == 'cancelled';
                }).toList();

                if (items.isEmpty) return _buildEmptyState(cs);

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(context, items[index], cs)
                        .animate(delay: (80 * index).ms)
                        .fadeIn(duration: 400.ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded, size: 52, color: cs.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            _selectedTabIndex == 0 ? 'No upcoming visits' : 'No past visits yet',
            style: TextStyle(color: cs.onSurface, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTabIndex == 0
                ? 'Book a doctor from Home and it will show up here.'
                : 'Completed and cancelled visits land in this list.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment apt, ColorScheme cs) {
    final paid = apt.isPaid;
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Navigator.push(
        context,
        PageTransitions.slideRight(AppointmentDetailScreen(appointment: apt)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (apt.doctorImage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: NetworkAvatar(
                    url: apt.doctorImage,
                    size: 52,
                    radius: 16,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(apt.doctorName,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 17, color: cs.onSurface)),
                    const SizedBox(height: 4),
                    Text(apt.doctorSpecialty,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _chip(
                    apt.status.toUpperCase(),
                    apt.status == 'cancelled'
                        ? cs.error
                        : apt.status == 'completed'
                            ? cs.onSurfaceVariant
                            : const Color(0xFF0F766E),
                  ),
                  const SizedBox(height: 6),
                  _chip(paid ? 'PAID' : 'UNPAID',
                      paid ? const Color(0xFF059669) : const Color(0xFFD97706)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('${apt.date} · ${apt.time}',
                  style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
              const Spacer(),
              Text(Formatters.fee(apt.fee),
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    );
  }
}
