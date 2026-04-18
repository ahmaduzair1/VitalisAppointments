import 'package:flutter/material.dart';
import '../core/app_colors.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment'), backgroundColor: AppColors.background, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundImage: NetworkImage(widget.doctor['image'])),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(widget.doctor['specialty'], style: const TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Select Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                bool isSelected = selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedDateIndex = index),
                  child: Container(
                    width: 70,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(days[index], style: TextStyle(color: isSelected ? Colors.white70 : AppColors.textLight)),
                        const SizedBox(height: 8),
                        Text(dates[index], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Text('Morning Slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(times.length, (index) {
                bool isSelected = selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimeIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
                    ),
                    child: Text(times[index], style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textDark, fontWeight: FontWeight.w600)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Booked Successfully!')));
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 56)),
            child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}