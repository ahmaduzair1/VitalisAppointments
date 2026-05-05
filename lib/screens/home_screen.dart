import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../core/mock_data.dart';
import '../widgets/section_header.dart';
import '../widgets/category_chip.dart';
import '../widgets/doctor_card.dart';
import 'doctor_list_screen.dart';
import 'doctor_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'General', 'icon': Icons.medical_services_rounded},
    {'label': 'Dentist', 'icon': Icons.clean_hands_rounded},
    {'label': 'Heart', 'icon': Icons.favorite_rounded},
    {'label': 'Brain', 'icon': Icons.psychology_rounded},
    {'label': 'Eye', 'icon': Icons.visibility_rounded},
    {'label': 'Bone', 'icon': Icons.accessibility_new_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final topDoctors = MockData.doctors.take(4).toList();
    final availableToday =
        MockData.doctors.where((d) => d['availableToday'] == true).toList();

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
                      Text(
                        'Hello, Sarah 👋',
                        style: TextStyle(
                          fontSize: 15,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vitalis',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _headerIcon(cs, Icons.notifications_none_rounded),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                          color: cs.outline.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: const NetworkImage(
                              'https://i.pravatar.cc/150?img=44'),
                          backgroundColor: cs.onSurfaceVariant.withOpacity(0.08),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.outline.withOpacity(0.5),
                    ),
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
                          color: cs.onSurface.withOpacity(0.06),
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

          // ── Top Doctors (horizontal scroll) ─────────────
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
              child: SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: topDoctors.length,
                  itemBuilder: (context, index) {
                    final doc = topDoctors[index];
                    return DoctorCard(
                      doctor: doc,
                      isCompact: true,
                      onTap: () => Navigator.push(
                        context,
                        PageTransitions.slideRight(
                            DoctorProfileScreen(doctor: doc)),
                      ),
                    ).animate(delay: (300 + index * 80).ms).fadeIn(
                        duration: 400.ms);
                  },
                ),
              ),
            ),
          ),

          // ── Available Today ─────────────────────────────
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final doc = availableToday[index];
                  return DoctorCard(
                    doctor: doc,
                    onTap: () => Navigator.push(
                      context,
                      PageTransitions.slideRight(
                          DoctorProfileScreen(doctor: doc)),
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
                childCount: availableToday.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(ColorScheme cs, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.onSurface.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(color: cs.outline.withOpacity(0.5)),
      ),
      child: Icon(icon, size: 22, color: cs.onSurface),
    );
  }
}
