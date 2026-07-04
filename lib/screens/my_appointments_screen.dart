import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/vitalis_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _selectedTabIndex = 0;

  /// Returns a real-time Firestore stream filtered by the current user
  /// and by status (upcoming vs completed/cancelled).
  Stream<QuerySnapshot> _appointmentsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance.collection('appointments');

    if (_selectedTabIndex == 0) {
      // Upcoming: status == 'upcoming'
      return collection
          .where('patientId', isEqualTo: uid)
          .where('status', isEqualTo: 'upcoming')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      // Past: status in ['completed', 'cancelled']
      return collection
          .where('patientId', isEqualTo: uid)
          .where('status', whereIn: ['completed', 'cancelled'])
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Appointments',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -1.0,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Manage your upcoming and past visits.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Tab selector ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTab('Upcoming', 0),
                  _buildTab('Past', 1),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 20),

          // ── Real-time appointment list ───────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _appointmentsStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 56,
                              color: cs.error.withValues(alpha: 0.6)),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your connection and try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(cs);
                }

                // Data state
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    return _buildAppointmentCard(context, data, cs)
                        .animate(delay: (300 + index * 100).ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOut);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Beautiful empty state ─────────────────────────────────
  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_rounded,
                size: 48, color: cs.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedTabIndex == 0
                ? 'No upcoming appointments'
                : 'No past appointments',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _selectedTabIndex == 0
                  ? 'Book your first appointment and it will appear here.'
                  : 'Your completed visits will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      )
          .animate(delay: 300.ms)
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }

  // ── Tab widget ────────────────────────────────────────────
  Widget _buildTab(String label, int index) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Appointment card ──────────────────────────────────────
  Widget _buildAppointmentCard(
      BuildContext context, Map<String, dynamic> apt, ColorScheme cs) {
    final status = (apt['status'] as String? ?? '').toLowerCase();
    final Color statusColor;
    final Color statusBgColor;
    final String statusLabel;

    switch (status) {
      case 'upcoming':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        statusLabel = 'UPCOMING';
      case 'completed':
        statusColor = cs.onSurfaceVariant;
        statusBgColor = cs.onSurfaceVariant.withValues(alpha: 0.1);
        statusLabel = 'COMPLETED';
      case 'cancelled':
        statusColor = cs.error;
        statusBgColor = cs.error.withValues(alpha: 0.1);
        statusLabel = 'CANCELLED';
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        statusLabel = status.toUpperCase();
    }

    final doctorImage = apt['doctorImage'] as String?;

    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing details for ${apt['doctorName'] ?? 'Doctor'}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Subtle background watermark
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.medical_information_rounded,
                size: 120,
                color: cs.onSurface.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Doctor info row ─────────────────────
                  Row(
                    children: [
                      // Doctor avatar
                      if (doctorImage != null && doctorImage.isNotEmpty)
                        Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color:
                                cs.onSurfaceVariant.withValues(alpha: 0.08),
                            image: DecorationImage(
                              image: NetworkImage(doctorImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      // Name + specialty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apt['doctorName'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              apt['doctorSpecialty'] ?? '',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Date & time row ─────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.calendar_month_rounded,
                            color: cs.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt['date'] ?? '',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            apt['time'] ?? '',
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}