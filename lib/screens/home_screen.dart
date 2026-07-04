import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/page_transitions.dart';
import '../widgets/section_header.dart';
import '../widgets/category_chip.dart';
import '../widgets/doctor_card.dart';
import 'doctor_list_screen.dart';
import 'doctor_profile_screen.dart';
import 'alerts_screen.dart';
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
    {'label': 'Brain', 'icon': Icons.psychology_rounded},
    {'label': 'Eye', 'icon': Icons.visibility_rounded},
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
      case 'Brain':
        return specialty.contains('neuro');
      case 'Bone':
        return specialty.contains('ortho') || specialty.contains('bone');
      case 'Eye':
        return specialty.contains('ophthalmol') || specialty.contains('eye');
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
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: const NetworkImage(
                                'https://i.pravatar.cc/150?img=44'),
                            backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()));
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox());
              }

              // Filter for 'availableToday' = true
              final availableTodayDocs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['availableToday'] == true && _matchesCategory(data);
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