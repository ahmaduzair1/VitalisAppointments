import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/mock_data.dart';
import 'doctor_profile_screen.dart';

class DoctorListingsScreen extends StatelessWidget {
  const DoctorListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Specialists', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: MockData.doctors.length,
        itemBuilder: (context, index) {
          final doc = MockData.doctors[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 30, backgroundImage: NetworkImage(doc['image'])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(doc['specialty'], style: const TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.orange, size: 20),
                    Text(' ${doc['rating']}'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_month, size: 16, color: AppColors.textLight),
                      SizedBox(width: 8),
                      Text('Next Available: Today, 2:30 PM'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doc))),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                    child: const Text('Book Consultation', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}