import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../core/mock_data.dart';
import '../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class DoctorListingsScreen extends StatelessWidget {
  const DoctorListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Specialists'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: MockData.doctors.length,
        itemBuilder: (context, index) {
          final doc = MockData.doctors[index];
          return DoctorCard(
            doctor: doc,
            showBookButton: true,
            onTap: () => Navigator.push(
              context,
              PageTransitions.slideRight(DoctorProfileScreen(doctor: doc)),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: (index * 100).ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: (index * 100).ms, curve: Curves.easeOut);
        },
      ),
    );
  }
}