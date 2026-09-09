import 'package:flutter/material.dart';

import '../../core/constants/page_transitions.dart';
import '../../core/formatters.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/vitalis_card.dart';
import '../appointment_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _payFilter = 'all';
  String _statusFilter = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    AppointmentService.instance.backfillUpcomingSlots();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: StreamBuilder<List<Appointment>>(
        stream: AppointmentService.instance.watchAllForAdmin(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];
          final paid = all.where((a) => a.isPaid).length;
          final unpaid = all.length - paid;
          final upcoming = all.where((a) => a.isUpcoming).length;

          final filtered = all.where((a) {
            final payOk = _payFilter == 'all' ||
                (_payFilter == 'paid' && a.isPaid) ||
                (_payFilter == 'unpaid' && !a.isPaid);
            final statusOk = _statusFilter == 'all' || a.status == _statusFilter;
            final q = _search.toLowerCase();
            final searchOk = q.isEmpty ||
                a.patientName.toLowerCase().contains(q) ||
                a.doctorName.toLowerCase().contains(q);
            return payOk && statusOk && searchOk;
          }).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hospital board',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.8)),
                      const SizedBox(height: 6),
                      Text(
                        'Who booked, with which doctor, and who has paid.',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _stat(cs, '${all.length}', 'Bookings', Icons.event_note_rounded),
                          const SizedBox(width: 8),
                          _stat(cs, '$paid', 'Paid', Icons.verified_rounded),
                          const SizedBox(width: 8),
                          _stat(cs, '$unpaid', 'Unpaid', Icons.hourglass_bottom_rounded),
                          const SizedBox(width: 8),
                          _stat(cs, '$upcoming', 'Upcoming', Icons.upcoming_rounded),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Search patient or doctor',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterChip('All pay', 'all', _payFilter, (v) => _payFilter = v),
                          _filterChip('Paid', 'paid', _payFilter, (v) => _payFilter = v),
                          _filterChip('Unpaid', 'unpaid', _payFilter, (v) => _payFilter = v),
                          _filterChip('Upcoming', 'upcoming', _statusFilter, (v) => _statusFilter = v),
                          _filterChip('Done', 'completed', _statusFilter, (v) => _statusFilter = v),
                          _filterChip('Cancelled', 'cancelled', _statusFilter, (v) => _statusFilter = v),
                          _filterChip('All status', 'all', _statusFilter, (v) => _statusFilter = v),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text('No matching bookings',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      return VitalisCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () => Navigator.push(
                          context,
                          PageTransitions.slideRight(
                            AppointmentDetailScreen(appointment: a, isAdmin: true),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(a.patientName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: cs.onSurface)),
                                ),
                                Text(
                                  a.isPaid ? 'PAID' : 'UNPAID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: a.isPaid
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Doctor: ${a.doctorName}',
                                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
                            Text(a.doctorSpecialty,
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text('${a.date} · ${a.time} · ${a.status}',
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(Formatters.fee(a.fee),
                                style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
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

  Widget _stat(ColorScheme cs, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: cs.onSurface)),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    String value,
    String group,
    void Function(String) onSelect,
  ) {
    final selected = group == value;
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => onSelect(value)),
      selectedColor: cs.primary.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? cs.primary : cs.onSurface,
        fontSize: 12,
      ),
    );
  }
}
