import 'package:flutter/material.dart';

import '../core/schedule.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/time_slot_chip.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';

class RescheduleScreen extends StatefulWidget {
  final Appointment appointment;
  const RescheduleScreen({super.key, required this.appointment});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  late final List<DateTime> _dates;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dates = VisitSchedule.nextDays();
    final current = VisitSchedule.parseDate(widget.appointment.date);
    if (current != null) {
      final match = _dates.indexWhere((d) => VisitSchedule.isSameDay(d, current));
      if (match >= 0) _selectedDateIndex = match;
    }
    _selectedTimeIndex = VisitSchedule.allSlots.indexOf(widget.appointment.time);
  }

  String get _selectedTime =>
      _selectedTimeIndex >= 0 && _selectedTimeIndex < VisitSchedule.allSlots.length
          ? VisitSchedule.allSlots[_selectedTimeIndex]
          : '';

  String get _selectedDate => VisitSchedule.formatDate(_dates[_selectedDateIndex]);

  Future<void> _save() async {
    if (_selectedTime.isEmpty) return;
    setState(() => _saving = true);
    try {
      await AppointmentService.instance.reschedule(
        widget.appointment,
        date: _selectedDate,
        time: _selectedTime,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Visit moved to $_selectedDate at $_selectedTime')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<Set<String>>(
      stream: AppointmentService.instance.watchTakenTimes(
        doctorId: widget.appointment.doctorId,
        date: _selectedDate,
        exceptAppointmentId: widget.appointment.id,
      ),
      builder: (context, snapshot) {
        final taken = snapshot.data ?? {};
        return Scaffold(
      appBar: AppBar(title: const Text('Reschedule visit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          VitalisCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.appointment.doctorName,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 17, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(
                  'Currently ${widget.appointment.date} at ${widget.appointment.time}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Pick a new day',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                final date = _dates[index];
                final selected = _selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedDateIndex = index;
                    if (_selectedTime.isNotEmpty &&
                        VisitSchedule.isSlotInPast(date, _selectedTime)) {
                      _selectedTimeIndex = -1;
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: selected ? null : Border.all(color: cs.outline),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          index == 0 ? 'Today' : VisitSchedule.dayName(date),
                          style: TextStyle(
                            color: selected
                                ? cs.onPrimary.withValues(alpha: 0.85)
                                : cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: selected ? cs.onPrimary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('Choose a time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(_selectedDate, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 16),
          _slotGroup(cs, 'Morning', VisitSchedule.morningSlots, 0, taken),
          const SizedBox(height: 16),
          _slotGroup(cs, 'Afternoon', VisitSchedule.afternoonSlots, VisitSchedule.morningSlots.length, taken),
          const SizedBox(height: 16),
          _slotGroup(
            cs,
            'Evening',
            VisitSchedule.eveningSlots,
            VisitSchedule.morningSlots.length + VisitSchedule.afternoonSlots.length,
            taken,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.3))),
        ),
        child: SafeArea(
          child: VitalisButton(
            label: 'Save new time',
            isLoading: _saving,
            onPressed: _selectedTime.isEmpty ||
                    _saving ||
                    taken.contains(_selectedTime)
                ? null
                : _save,
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _slotGroup(ColorScheme cs, String label, List<String> slots, int offset, Set<String> taken) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(slots.length, (i) {
            final globalIndex = offset + i;
            final takenSlot = taken.contains(slots[i]);
            final disabled = takenSlot ||
                VisitSchedule.isSlotInPast(_dates[_selectedDateIndex], slots[i]);
            return TimeSlotChip(
              time: slots[i],
              isSelected: _selectedTimeIndex == globalIndex,
              isDisabled: disabled,
              isTaken: takenSlot,
              onTap: () => setState(() => _selectedTimeIndex = globalIndex),
            );
          }),
        ),
      ],
    );
  }
}
