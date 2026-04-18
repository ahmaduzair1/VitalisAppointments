import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Alerts', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Stay updated with your latest health activities.', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 32),
          const Text('TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
          const SizedBox(height: 16),
          _buildAlertCard(Icons.calendar_today, 'Appointment Reminder', 'Your session with Dr. Aris Thorne is scheduled for tomorrow at 10:30 AM.', true),
          const SizedBox(height: 16),
          _buildAlertCard(Icons.chat_bubble, 'New Message', '"The blood work results are in. Everything looks stable..."', false),
        ],
      ),
    );
  }

  Widget _buildAlertCard(IconData icon, String title, String desc, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: isPrimary ? AppColors.primary : AppColors.success, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isPrimary ? AppColors.primary.withOpacity(0.1) : AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: isPrimary ? AppColors.primary : AppColors.success)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textLight, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}