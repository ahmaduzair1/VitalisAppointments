import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../core/mock_data.dart';
import '../widgets/stat_card.dart';
import '../widgets/time_slot_chip.dart';
import '../widgets/vitalis_button.dart';
import 'booking_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedTimeIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final doc = widget.doctor;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ─────────────────────────────────
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: cs.onSurface,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Doctor image
                  Hero(
                    tag: 'doctor_avatar_${doc['name']}',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(doc['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.3),
                          theme.scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Doctor info ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -32, 0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Verified badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'VERIFIED',
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1, end: 0, duration: 300.ms),

                  const SizedBox(height: 12),

                  // Name
                  Text(
                    doc['name'],
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // Specialty + Location
                  Text(
                    doc['specialty'],
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: cs.onSurfaceVariant, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        doc['location'],
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // ── Stats row ───────────────────────────
                  Row(
                    children: [
                      StatCard(
                        icon: Icons.star_rounded,
                        value: doc['rating'].toString(),
                        label: '${doc['reviews']} Reviews',
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        icon: Icons.workspace_premium_rounded,
                        value: doc['experience'].split(' ')[0],
                        label: 'Years Exp.',
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        icon: Icons.people_rounded,
                        value: doc['patients'],
                        label: 'Patients',
                      ),
                    ],
                  )
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0, duration: 500.ms),

                  const SizedBox(height: 32),

                  // ── About section ───────────────────────
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doc['about'],
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      height: 1.7,
                      fontSize: 14,
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // ── Available Time Slots ─────────────────
                  Text(
                    'Available Slots',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Morning',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(MockData.morningSlots.length, (i) {
                      return TimeSlotChip(
                        time: MockData.morningSlots[i],
                        isSelected: _selectedTimeIndex == i,
                        onTap: () =>
                            setState(() => _selectedTimeIndex = i),
                      );
                    }),
                  ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),
                  Text(
                    'Afternoon',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        List.generate(MockData.afternoonSlots.length, (i) {
                      final globalIndex = MockData.morningSlots.length + i;
                      return TimeSlotChip(
                        time: MockData.afternoonSlots[i],
                        isSelected: _selectedTimeIndex == globalIndex,
                        onTap: () => setState(
                            () => _selectedTimeIndex = globalIndex),
                      );
                    }),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        ],
      ),

      // ── Sticky bottom CTA ──────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            top: BorderSide(color: cs.outline.withOpacity(0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Fee',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${doc['fee']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: VitalisButton(
                  label: 'Book Appointment',
                  onPressed: () => Navigator.push(
                    context,
                    PageTransitions.slideRight(
                        BookingScreen(doctor: doc)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}