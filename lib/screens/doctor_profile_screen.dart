import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'book_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(doctor['image']), fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(100)),
                    child: const Text('VERIFIED PROFESSIONAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(doctor['name'], style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(doctor['specialty'], style: const TextStyle(fontSize: 16, color: AppColors.primary)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(Icons.star, doctor['rating'].toString(), '${doctor['reviews']} Reviews'),
                      _buildStatCard(Icons.workspace_premium, doctor['experience'].split(' ')[0], 'Experience'),
                      _buildStatCard(Icons.people, doctor['patients'], 'Patients'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    '${doctor['name']} is a board-certified specialist focusing on preventive care and lifestyle-based interventions. Known for a patient-first approach.',
                    style: const TextStyle(color: AppColors.textLight, height: 1.5),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAppointmentScreen(doctor: doctor))),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Book Appointment →', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ],
      ),
    );
  }
}