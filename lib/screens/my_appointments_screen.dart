import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Appointments', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Manage your health journey and upcoming visits.', style: TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
              child: Row(
                children: [
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Text('Upcoming', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
                  Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, child: const Text('Past', style: TextStyle(color: AppColors.textLight)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildAppointmentCard('Dr. Julian Vane', 'Cardiologist', 'Oct 24, 2023', '09:30 AM', 'CONFIRMED', AppColors.success),
                  _buildAppointmentCard('Dr. Sarah Jenkins', 'Dermatologist', 'Oct 28, 2023', '02:15 PM', 'PENDING', Colors.blue),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(String name, String spec, String date, String time, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(spec, style: const TextStyle(color: AppColors.textLight, fontSize: 12))]),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(date, style: const TextStyle(fontWeight: FontWeight.w600))]))),
              const SizedBox(width: 12),
              Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.access_time, size: 16, color: AppColors.primary), const SizedBox(width: 8), Text(time, style: const TextStyle(fontWeight: FontWeight.w600))]))),
            ],
          )
        ],
      ),
    );
  }
}