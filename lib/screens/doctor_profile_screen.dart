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
                  Hero(
                    tag: 'doctor_avatar_${doc['name'] ?? 'Unknown'}',
                    child: Container(
                      decoration: BoxDecoration(
                        image: (doc['image'] as String?)?.isNotEmpty == true
                            ? DecorationImage(
                                image: NetworkImage(doc['image']),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: cs.primary.withValues(alpha: 0.1),
                      ),
                      child: (doc['image'] as String?)?.isNotEmpty != true
                          ? Center(
                              child: Icon(Icons.person_rounded,
                                  size: 80,
                                  color: cs.primary.withValues(alpha: 0.5)),
                            )
                          : null,
                    ),
                  ),
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
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                        .slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 12),

                    Text(
                      doc['name'] ?? 'Unknown Doctor',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ).animate(delay: 100.ms).fadeIn(),

                    const SizedBox(height: 8),

                    Text(
                      doc['specialty'] ?? 'General',
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doc['location'] ?? 'Vitalis Clinic',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.star_rounded,
                            value: (doc['rating'] ?? 0.0).toString(),
                            label: '${doc['reviews'] ?? '0'} Reviews',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.workspace_premium_rounded,
                            value: (doc['experience'] ?? '0 years').toString().split(' ')[0],
                            label: 'Years Exp.',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.people_rounded,
                            value: (doc['patients'] ?? '0').toString(),
                            label: 'Patients',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

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
                      doc['about'] ?? 'An experienced specialist dedicated to providing top-quality care to their patients.',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                      List.generate(MockData.morningSlots.length, (i) {
                        return TimeSlotChip(
                          time: MockData.morningSlots[i],
                          isSelected: _selectedTimeIndex == i,
                          onTap: () =>
                              setState(() => _selectedTimeIndex = i),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                      List.generate(MockData.afternoonSlots.length, (i) {
                        final index = MockData.morningSlots.length + i;
                        return TimeSlotChip(
                          time: MockData.afternoonSlots[i],
                          isSelected: _selectedTimeIndex == index,
                          onTap: () =>
                              setState(() => _selectedTimeIndex = index),
                        );
                      }),
                    ),

                    const SizedBox(height: 100), // padding for bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar FIXED ──────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced padding
        decoration: BoxDecoration(
          color: theme.cardColor,
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
            children: [ // Removed spaceBetween, relying purely on Expanded
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Fee', // Shortened label
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '\$${doc['fee'] ?? 0}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 16), // Reduced the gap from 24 to 16

              Expanded(
                child: VitalisButton(
                  label: 'Book Now', // Shortened button text to guarantee it fits!
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransitions.fadeSlide(BookingScreen(doctor: doc)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}