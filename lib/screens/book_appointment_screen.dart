import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/vitalis_button.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int selectedDateIndex = 1;
  int selectedTimeIndex = 1;
  final List<String> dates = ['14', '15', '16', '17'];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu'];
  final List<String> times = ['09:00 AM', '09:30 AM', '10:00 AM', '11:30 AM'];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Doctor info card ─────────────────────────
            VitalisCard(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary.withAlpha(51), width: 2),
                    ),
                    child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(widget.doctor['image']), backgroundColor: colors.inputFill),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor['name'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: colors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(widget.doctor['specialty'], style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.xl),

            // ── Date selector ────────────────────────────
            Text('Select Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                bool isSelected = selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedDateIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 92,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : colors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: isSelected ? null : Border.all(color: colors.divider),
                      boxShadow: isSelected ? [BoxShadow(color: colors.primary.withAlpha(51), blurRadius: 12, offset: const Offset(0, 4))] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(days[index], style: TextStyle(color: isSelected ? Colors.white70 : colors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(dates[index], style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : colors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }),
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: AppSpacing.xl),

            // ── Time selector ────────────────────────────
            Text('Morning Slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(times.length, (index) {
                bool isSelected = selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimeIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary.withAlpha(26) : colors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(color: isSelected ? colors.primary : colors.divider, width: isSelected ? 1.5 : 1),
                    ),
                    child: Text(
                      times[index],
                      style: TextStyle(color: isSelected ? colors.primary : colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                );
              }),
            ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.divider.withAlpha(77), width: 0.5)),
        ),
        child: SafeArea(
          child: VitalisButton(
            label: 'Confirm Booking',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment Booked Successfully!')),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ),
    );
  }
}