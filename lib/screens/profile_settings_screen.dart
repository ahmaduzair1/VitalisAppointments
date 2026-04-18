import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=44')),
            const SizedBox(height: 16),
            Text('Sarah Jenkins', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Patient ID: #VT-99204', style: TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  _buildListTile(Icons.medical_information, 'Medical History', 'Records, labs, and immunizations'),
                  const Divider(height: 1, indent: 60),
                  _buildListTile(Icons.payment, 'Payment Methods', 'Manage billing and insurance'),
                  const Divider(height: 1, indent: 60),
                  _buildListTile(Icons.privacy_tip, 'Privacy Settings', 'Data sharing and HIPAA consent'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}