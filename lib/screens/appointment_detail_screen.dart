import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/review_service.dart';
import '../core/constants/page_transitions.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import 'reschedule_screen.dart';
import 'review_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;
  final bool isAdmin;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    this.isAdmin = false,
  });

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Appointment _apt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _apt = widget.appointment;
  }

  Future<void> _cancelVisit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Cancel this visit?'),
          content: Text(
            'This will cancel your appointment with ${_apt.doctorName} on ${_apt.date} at ${_apt.time}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep visit', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Cancel visit',
                  style: TextStyle(color: cs.error, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await _run(() => AppointmentService.instance.cancel(_apt));
    }
  }

  Future<void> _reschedule() async {
    final changed = await Navigator.push<bool>(
      context,
      PageTransitions.slideRight(RescheduleScreen(appointment: _apt)),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Visit details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          VitalisCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_apt.doctorName,
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(_apt.doctorSpecialty, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 16),
                _row('Patient', _apt.patientName),
                _row('Date', _apt.date),
                _row('Time', _apt.time),
                _row('Location', _apt.location),
                _row('Fee', Formatters.fee(_apt.fee)),
                _row('Status', _apt.status),
                _row('Payment', _apt.isPaid ? 'Paid (${_apt.paymentMethod})' : 'Unpaid'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (!_busy && _apt.isUpcoming && !_apt.isPaid)
            VitalisButton(
              label: 'Pay now',
              onPressed: () => _run(() => AppointmentService.instance.markPaid(_apt)),
            ),
          if (!_busy && _apt.isUpcoming) ...[
            const SizedBox(height: 10),
            VitalisButton(
              label: 'Reschedule',
              variant: VitalisButtonVariant.secondary,
              onPressed: _reschedule,
            ),
            const SizedBox(height: 10),
            VitalisButton(
              label: 'Cancel visit',
              variant: VitalisButtonVariant.secondary,
              onPressed: _cancelVisit,
            ),
          ],
          if (!_busy && widget.isAdmin) ...[
            const SizedBox(height: 16),
            Text('Admin actions',
                style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 10),
            if (_apt.isUpcoming)
              VitalisButton(
                label: 'Mark completed',
                onPressed: () =>
                    _run(() => AppointmentService.instance.updateStatus(_apt, 'completed')),
              ),
            if (!_apt.isPaid) ...[
              const SizedBox(height: 10),
              VitalisButton(
                label: 'Mark as paid',
                variant: VitalisButtonVariant.secondary,
                onPressed: () => _run(
                    () => AppointmentService.instance.markPaid(_apt, method: 'clinic')),
              ),
            ],
          ],
          if (!_busy &&
              !widget.isAdmin &&
              ReviewService.instance.isEligible(_apt)) ...[
            const SizedBox(height: 16),
            VitalisButton(
              label: 'Leave a review',
              variant: VitalisButtonVariant.secondary,
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransitions.slideRight(ReviewScreen(appointment: _apt)),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
