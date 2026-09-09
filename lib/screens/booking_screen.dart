import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/formatters.dart';
import '../core/schedule.dart';
import '../services/appointment_service.dart';
import '../widgets/time_slot_chip.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/network_avatar.dart';
import '../core/constants/page_transitions.dart';
import '../services/auth_service.dart';
import 'success_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  String _paymentMethod = 'clinic';
  bool _isLoading = false;

  late final List<DateTime> _dates;

  final List<String> _morningSlots = VisitSchedule.morningSlots;
  final List<String> _afternoonSlots = VisitSchedule.afternoonSlots;
  final List<String> _eveningSlots = VisitSchedule.eveningSlots;

  @override
  void initState() {
    super.initState();
    _dates = VisitSchedule.nextDays();
  }

  String _dayName(DateTime date) => VisitSchedule.dayName(date);

  String get _selectedTime {
    if (_selectedTimeIndex < 0) return '';
    final allSlots = [..._morningSlots, ..._afternoonSlots, ..._eveningSlots];
    if (_selectedTimeIndex < allSlots.length) return allSlots[_selectedTimeIndex];
    return '';
  }

  String get _selectedDateFormatted {
    return VisitSchedule.formatDate(_dates[_selectedDateIndex]);
  }

  Future<void> _processBooking() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final patientName = await AuthService().currentPatientName();
      await AppointmentService.instance.book(
        doctor: widget.doctor,
        date: _selectedDateFormatted,
        time: _selectedTime,
        paymentMethod: _paymentMethod,
        patientName: patientName,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeSlide(
          SuccessScreen(
            doctor: widget.doctor,
            date: _selectedDateFormatted,
            time: _selectedTime,
            paid: _paymentMethod != 'clinic',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final takenStream = AppointmentService.instance.watchTakenTimes(
      doctorId: '${widget.doctor['id'] ?? ''}',
      date: _selectedDateFormatted,
    );

    return StreamBuilder<Set<String>>(
      stream: takenStream,
      builder: (context, snapshot) {
        final taken = snapshot.data ?? {};
        return Scaffold(
      appBar: AppBar(
        title: const Text('Book visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    _buildStepDot(0, 'Date'),
                    _buildStepLine(0),
                    _buildStepDot(1, 'Time'),
                    _buildStepLine(1),
                    _buildStepDot(2, 'Pay'),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0
                        ? _buildDateStep(cs)
                        : _currentStep == 1
                            ? _buildTimeStep(cs, taken)
                            : _buildConfirmStep(theme, cs, taken),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.3))),
        ),
        child: SafeArea(
          child: VitalisButton(
            label: _currentStep == 2
                ? (_paymentMethod == 'clinic' ? 'Book & pay later' : 'Pay & confirm')
                : 'Continue',
            onPressed: _canContinue(taken) && !_isLoading
                ? () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      _processBooking();
                    }
                  }
                : null,
          ),
        ),
      ),
    );
      },
    );
  }

  bool _canContinue(Set<String> taken) {
    if (_currentStep == 1) {
      if (_selectedTimeIndex < 0) return false;
      return !_isUnavailable(_selectedTime, taken);
    }
    if (_currentStep == 2) {
      if (_selectedTimeIndex < 0) return false;
      return !_isUnavailable(_selectedTime, taken);
    }
    return true;
  }

  bool _isUnavailable(String time, Set<String> taken) {
    // While this booking is committing, the slot lock is ours — not a conflict.
    if (_isLoading && time == _selectedTime) return false;
    return taken.contains(time) ||
        VisitSchedule.isSlotInPast(_dates[_selectedDateIndex], time);
  }

  Widget _buildDateStep(ColorScheme cs) {
    return Column(
      key: const ValueKey('date'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VitalisCard(
          child: Row(
            children: [
              NetworkAvatar(
                url: '${widget.doctor['image'] ?? ''}',
                size: 48,
                radius: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor['name'] ?? 'Doctor',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor['specialty'] ?? '',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.fee(widget.doctor['fee']),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 28),
        Text(
          'Pick a day',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the next opening that works for you.',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedDateIndex == index;
              final date = _dates[index];
              final isToday = index == 0;
              return GestureDetector(
                onTap: () => setState(() => _selectedDateIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? null : Border.all(color: cs.outline),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : _dayName(date),
                        style: TextStyle(
                          color: isSelected
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
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStep(ColorScheme cs, Set<String> taken) {
    return Column(
      key: const ValueKey('time'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a time',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text(_selectedDateFormatted,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          'Booked times stay with that patient. Pick an open slot.',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        _slotGroup(cs, 'Morning', _morningSlots, 0, taken),
        const SizedBox(height: 20),
        _slotGroup(cs, 'Afternoon', _afternoonSlots, _morningSlots.length, taken),
        const SizedBox(height: 20),
        _slotGroup(
          cs,
          'Evening',
          _eveningSlots,
          _morningSlots.length + _afternoonSlots.length,
          taken,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _slotGroup(
    ColorScheme cs,
    String label,
    List<String> slots,
    int offset,
    Set<String> taken,
  ) {
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
            return TimeSlotChip(
              time: slots[i],
              isSelected: _selectedTimeIndex == globalIndex,
              isDisabled: _isUnavailable(slots[i], taken),
              isTaken: takenSlot,
              onTap: () => setState(() => _selectedTimeIndex = globalIndex),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(ThemeData theme, ColorScheme cs, Set<String> taken) {
    return Column(
      key: const ValueKey('confirm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm & pay',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 16),
        VitalisCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  NetworkAvatar(
                    url: '${widget.doctor['image'] ?? ''}',
                    size: 56,
                    radius: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor['name'] ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 17, color: cs.onSurface)),
                        const SizedBox(height: 4),
                        Text(widget.doctor['specialty'] ?? '',
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: cs.outline.withValues(alpha: 0.5)),
              ),
              _buildDetailRow(cs, Icons.calendar_today_rounded, 'Date', _selectedDateFormatted),
              const SizedBox(height: 12),
              _buildDetailRow(cs, Icons.access_time_rounded, 'Time', _selectedTime),
              const SizedBox(height: 12),
              _buildDetailRow(
                  cs, Icons.location_on_outlined, 'Location', widget.doctor['location'] ?? 'Vitalis Clinic'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: cs.outline.withValues(alpha: 0.5)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Consultation fee',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
                  Text(Formatters.fee(widget.doctor['fee']),
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
                ],
              ),
            ],
          ),
        ),
        if (!_isLoading && taken.contains(_selectedTime))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'This time was just booked by someone else. Go back and pick another slot.',
              style: TextStyle(color: cs.error, fontSize: 13, height: 1.4),
            ),
          ),
        const SizedBox(height: 20),
        Text('Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 10),
        _payOption(
          cs,
          id: 'clinic',
          icon: Icons.local_hospital_outlined,
          title: 'Pay at clinic',
          subtitle: 'Settle the fee when you arrive. Shown as unpaid until then.',
        ),
        _payOption(
          cs,
          id: 'card',
          icon: Icons.credit_card_rounded,
          title: 'Pay now (card)',
          subtitle: 'Secure in-app confirmation. No card number is stored.',
        ),
        _payOption(
          cs,
          id: 'wallet',
          icon: Icons.account_balance_wallet_outlined,
          title: 'Pay now (wallet)',
          subtitle: 'Mark as paid with JazzCash / EasyPaisa style wallet.',
        ),
        if (_paymentMethod != 'clinic')
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'This demo confirms payment in the hospital record. Connect Stripe or a local gateway before going live.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.4),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _payOption(
    ColorScheme cs, {
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _paymentMethod == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _paymentMethod = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? cs.primary : cs.outline.withValues(alpha: 0.6),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? cs.primary : cs.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15, color: cs.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.35)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ColorScheme cs, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cs.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isCurrent ? 36 : 28,
            height: isCurrent ? 36 : 28,
            decoration: BoxDecoration(
              color: isActive ? cs.primary : cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive && !isCurrent
                  ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive ? cs.onPrimary : cs.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final cs = Theme.of(context).colorScheme;
    final isCompleted = _currentStep > afterStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 3,
          decoration: BoxDecoration(
            color: isCompleted ? cs.primary : cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}