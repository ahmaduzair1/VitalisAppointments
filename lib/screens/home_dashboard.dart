import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/mock_data.dart';
import 'doctor_listings_screen.dart';
import 'doctor_profile_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: AppColors.textDark, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(width: 12),
                    Text('Vitalis', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const Icon(Icons.search, size: 28),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors, clinics, or specialties',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categories', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('See All', style: TextStyle(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryItem(Icons.medical_services, 'General', true),
                  _buildCategoryItem(Icons.clean_hands, 'Dentist', false),
                  _buildCategoryItem(Icons.favorite, 'Cardiology', false),
                  _buildCategoryItem(Icons.psychology, 'Psychiatry', false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Upcoming Appointment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tomorrow, 10:00 AM', style: TextStyle(color: Colors.white70)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(100)),
                        child: const Text('CONFIRMED', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Dr. Julianne Moore', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      const Text('Heart Center, Block B', style: TextStyle(color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Featured Doctors', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorListingsScreen())),
                  child: const Text('View all', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...MockData.doctors.take(2).map((doc) => _buildDoctorCard(context, doc)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doc) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doc))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundImage: NetworkImage(doc['image'])),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(' ${doc['rating']}'),
                        ],
                      )
                    ],
                  ),
                  Text(doc['specialty'], style: const TextStyle(color: AppColors.textLight)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text(doc['experience'], style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}