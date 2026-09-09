import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/page_transitions.dart';
import '../core/schedule.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/section_header.dart';
import '../widgets/category_chip.dart';
import '../widgets/doctor_card.dart';
import '../widgets/vitalis_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/network_avatar.dart';
import 'doctor_list_screen.dart';
import 'doctor_profile_screen.dart';
import 'alerts_screen.dart';
import 'appointment_detail_screen.dart';
import 'profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps_rounded},
    {'label': 'General', 'icon': Icons.medical_services_rounded},
    {'label': 'Dentist', 'icon': Icons.clean_hands_rounded},
    {'label': 'Heart', 'icon': Icons.favorite_rounded},
    {'label': 'Women', 'icon': Icons.pregnant_woman_rounded},
    {'label': 'ENT', 'icon': Icons.hearing_rounded},
    {'label': 'Mind', 'icon': Icons.psychology_rounded},
    {'label': 'Child', 'icon': Icons.child_care_rounded},
    {'label': 'Bone', 'icon': Icons.accessibility_new_rounded},
  ];

  String get _selectedCategory =>
      _categories[_selectedCategoryIndex]['label'] as String;

  /// Returns true if the doctor's specialty matches the currently
  /// selected category filter. 'All' matches everything.
  bool _matchesCategory(Map<String, dynamic> data) {
    if (_selectedCategory == 'All') return true;
    final specialty = (data['specialty'] as String? ?? '').toLowerCase();
    switch (_selectedCategory) {
      case 'Heart':
        return specialty.contains('cardio');
      case 'Women':
        return specialty.contains('gynecol') || specialty.contains('obstet');
      case 'ENT':
        return specialty.contains('ent');
      case 'Mind':
        return specialty.contains('psychiatr') || specialty.contains('psycholog');
      case 'Child':
        return specialty.contains('pediatr');
      case 'Bone':
        return specialty.contains('ortho') || specialty.contains('bone');
      case 'Dentist':
        return specialty.contains('dentist');
      case 'General':
        return specialty.contains('general');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser?.uid)
                            .get(),
                        builder: (context, snapshot) {
                          String firstName = '...';

                          if (snapshot.hasData && snapshot.data!.exists) {
                            final userData = snapshot.data!.data() as Map<String, dynamic>;
                            final fullName = userData['name'] ?? 'Guest';
                            firstName = fullName.split(' ')[0];
                          }

                          return Text(
                            'Hello, $firstName 👋',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vitalis',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context, PageTransitions.fade(const AlertsScreen())),
                        child: _headerIcon(cs, Icons.notifications_none_rounded),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.push(context, PageTransitions.fade(const ProfileSettingsScreen())),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outline.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: NetworkAvatar(
                            url: currentUser?.photoURL ?? '',
                            size: 40,
                            radius: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),

          SliverToBoxAdapter(
            child: StreamBuilder<List<Appointment>>(
              stream: AppointmentService.instance.watchMine(),
              builder: (context, snapshot) {
                final upcoming = (snapshot.data ?? [])
                    .where((a) => a.isUpcoming)
                    .toList();
                Appointment? next;
                for (final apt in upcoming) {
                  final p = VisitSchedule.proximity(apt.date, apt.time);
                  if (p == VisitProximity.today || p == VisitProximity.tomorrow) {
                    next = apt;
                    break;
                  }
                }
                if (next == null) return const SizedBox.shrink();
                final today =
                    VisitSchedule.proximity(next.date, next.time) == VisitProximity.today;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: VitalisCard(
                    onTap: () => Navigator.push(
                      context,
                      PageTransitions.slideRight(
                        AppointmentDetailScreen(appointment: next!),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                today ? 'Visit today' : 'Visit tomorrow',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${next.doctorName} at ${next.time}. Reschedule or cancel from Settings.',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Search bar ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  PageTransitions.fadeSlide(const DoctorListScreen()),
                ),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: theme.brightness == Brightness.dark
                        ? Border.all(color: cs.outline.withValues(alpha: 0.3))
                        : null,
                    boxShadow: theme.brightness == Brightness.light
                        ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: cs.onSurfaceVariant, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Search doctors, specialties...',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                        Icon(Icons.tune_rounded, color: cs.onSurfaceVariant, size: 18),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            ),
          ),

          // ── Categories ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: SectionHeader(
                title: 'Categories',
                actionText: 'See All',
                onAction: () => Navigator.push(
                  context,
                  PageTransitions.slideRight(const DoctorListScreen()),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return CategoryChip(
                      icon: _categories[index]['icon'],
                      label: _categories[index]['label'],
                      isSelected: _selectedCategoryIndex == index,
                      onTap: () =>
                          setState(() => _selectedCategoryIndex = index),
                    );
                  },
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ),
          ),

          // ── Top Doctors (Real Firebase Data) ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: SectionHeader(
                title: 'Top Doctors',
                actionText: 'View All',
                onAction: () => Navigator.push(
                  context,
                  PageTransitions.slideRight(const DoctorListScreen()),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 190,
                    child: Center(
                      child: Text(
                        'Could not load doctors.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                    child: SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: ShimmerLoading(
                            width: 160,
                            height: 190,
                            borderRadius: 32,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox(height: 190, child: Center(child: Text("No doctors found in Database")));
                }

                // Filter by selected category, then take top 4
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _matchesCategory(data);
                }).take(4).toList();

                if (docs.isEmpty) {
                  return SizedBox(
                    height: 190,
                    child: Center(
                      child: Text(
                        'No doctors found for "$_selectedCategory"',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                  child: SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final doctorData = {...data, 'id': doc.id}; // Add ID

                        return DoctorCard(
                          doctor: doctorData,
                          isCompact: true,
                          onTap: () => Navigator.push(
                            context,
                            PageTransitions.slideRight(
                                DoctorProfileScreen(doctor: doctorData)),
                          ),
                        ).animate(delay: (300 + index * 80).ms).fadeIn(duration: 400.ms);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Available Today (Real Firebase Data) ─────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: SectionHeader(
                title: 'Available Today',
                actionText: 'View All',
                onAction: () => Navigator.push(
                  context,
                  PageTransitions.slideRight(const DoctorListScreen()),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load doctors.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  sliver: SliverList.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) => ShimmerLoading.doctorCard(),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox());
              }

              // Filter for 'availableToday' = true
              final availableTodayDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['availableToday'] != false && _matchesCategory(data);
              }).toList();

              if (availableTodayDocs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text("No doctors available today")),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final doc = availableTodayDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final doctorData = {...data, 'id': doc.id};

                      return DoctorCard(
                        doctor: doctorData,
                        onTap: () => Navigator.push(
                          context,
                          PageTransitions.slideRight(
                              DoctorProfileScreen(doctor: doctorData)),
                        ),
                      )
                          .animate(delay: (400 + index * 100).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut);
                    },
                    childCount: availableTodayDocs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(ColorScheme cs, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.04),
        shape: BoxShape.circle,
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, size: 22, color: cs.onSurface),
    );
  }
}