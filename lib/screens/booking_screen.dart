import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/mock_data.dart';
import '../widgets/time_slot_chip.dart';
import '../widgets/vitalis_button.dart';
import '../widgets/vitalis_card.dart';
import '../core/constants/page_transitions.dart';
import 'success_screen.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0; // 0=date, 1=time, 2=confirm
  int _selectedDateIndex = 1;
  int _selectedTimeIndex = -1;

  // Generate next 7 days
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i)));
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _monthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }

  String get _selectedTime {
    if (_selectedTimeIndex < 0) return '';
    final allSlots = [...MockData.morningSlots, ...MockData.afternoonSlots];
    if (_selectedTimeIndex < allSlots.length) return allSlots[_selectedTimeIndex];
    return '';
  }

  String get _selectedDateFormatted {
    final date = _dates[_selectedDateIndex];
    return '${_monthName(date)} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
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
      body: Column(
        children: [
          // ── Step indicator ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                _buildStepDot(0, 'Date'),
                _buildStepLine(0),
                _buildStepDot(1, 'Time'),
                _buildStepLine(1),
                _buildStepDot(2, 'Confirm'),
              ],
            ),
          ),

          // ── Step content ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                child: _currentStep == 0
                    ? _buildDateStep(cs)
                    : _currentStep == 1
                        ? _buildTimeStep(cs)
                        : _buildConfirmStep(theme, cs),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(color: cs.outline.withOpacity(0.3)),
          ),
        ),
        child: SafeArea(
          child: VitalisButton(
            label: _currentStep == 2 ? 'Confirm Booking' : 'Continue',
            onPressed: _canContinue()
                ? () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        PageTransitions.fadeSlide(
                          SuccessScreen(
                            doctor: widget.doctor,
                            date: _selectedDateFormatted,
                            time: _selectedTime,
                          ),
                        ),
                      );
                    }
                  }
                : null,
          ),
        ),
      ),
    );
  }

  bool _canContinue() {
    if (_currentStep == 0) return true;
    if (_currentStep == 1) return _selectedTimeIndex >= 0;
    return true;
  }

  // ── Step 1: Date ────────────────────────────────────────
  Widget _buildDateStep(ColorScheme cs) {
    return Column(
      key: const ValueKey('date'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor info
        VitalisCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(widget.doctor['image']),
                backgroundColor: cs.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.doctor['specialty'],
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${widget.doctor['fee']}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 32),

        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Date selector
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
                    color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? null
                        : Border.all(color: cs.outline),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : _dayName(date),
                        style: TextStyle(
                          color: isSelected
                              ? cs.onPrimary.withOpacity(0.8)
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
                          color:
                              isSelected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  // ── Step 2: Time ────────────────────────────────────────
  Widget _buildTimeStep(ColorScheme cs) {
    return Column(
      key: const ValueKey('time'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Morning',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(MockData.morningSlots.length, (i) {
            return TimeSlotChip(
              time: MockData.morningSlots[i],
              isSelected: _selectedTimeIndex == i,
              onTap: () => setState(() => _selectedTimeIndex = i),
            );
          }),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        Text(
          'Afternoon',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(MockData.afternoonSlots.length, (i) {
            final globalIndex = MockData.morningSlots.length + i;
            return TimeSlotChip(
              time: MockData.afternoonSlots[i],
              isSelected: _selectedTimeIndex == globalIndex,
              onTap: () =>
                  setState(() => _selectedTimeIndex = globalIndex),
            );
          }),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        Text(
          'Evening',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(MockData.eveningSlots.length, (i) {
            final globalIndex =
                MockData.morningSlots.length + MockData.afternoonSlots.length + i;
            return TimeSlotChip(
              time: MockData.eveningSlots[i],
              isSelected: _selectedTimeIndex == globalIndex,
              onTap: () =>
                  setState(() => _selectedTimeIndex = globalIndex),
            );
          }),
        ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
      ],
    );
  }

  // ── Step 3: Confirm ─────────────────────────────────────
  Widget _buildConfirmStep(ThemeData theme, ColorScheme cs) {
    return Column(
      key: const ValueKey('confirm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        VitalisCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Doctor info
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(widget.doctor['image']),
                    backgroundColor: cs.primary.withOpacity(0.1),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor['specialty'],
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
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

              // Details
              _buildDetailRow(
                  cs, Icons.calendar_today_rounded, 'Date', _selectedDateFormatted),
              const SizedBox(height: 12),
              _buildDetailRow(
                  cs, Icons.access_time_rounded, 'Time', _selectedTime),
              const SizedBox(height: 12),
              _buildDetailRow(
                  cs, Icons.location_on_outlined, 'Location', widget.doctor['location']),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: cs.outline.withOpacity(0.5)),
              ),

              // Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Consultation Fee',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '\$${widget.doctor['fee']}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
      ],
    );
  }

  Widget _buildDetailRow(
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
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
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

  // ── Step indicator widgets ──────────────────────────────
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
              color: isActive ? cs.primary : cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
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
            color: isCompleted ? cs.primary : cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
