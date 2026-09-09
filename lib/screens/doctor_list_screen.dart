import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/page_transitions.dart';
import '../widgets/doctor_card.dart';
import '../widgets/shimmer_loading.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All',
    'General',
    'Cardiology',
    'Dentist',
    'Gynecologist',
    'ENT',
    'Psychiatrist',
    'Pediatric',
    'Orthopedic',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Find Doctors',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                height: 60,
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
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: cs.onSurface, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search by name or specialty...',
                      hintStyle: TextStyle(color: cs.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: cs.onSurfaceVariant, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: cs.onSurfaceVariant, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // ── Filter chips ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 8),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? null
                                : Border.all(
                                color: cs.outline),
                          ),
                          child: Center(
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                isSelected ? cs.onPrimary : cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
            ),

            // ── Real Firebase Doctor List ───────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
                builder: (context, snapshot) {
                  // 1. Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: 6,
                      itemBuilder: (context, index) => ShimmerLoading.doctorCard(),
                    );
                  }

                  // 2. Error
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading doctors"));
                  }

                  // 3. No data
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(cs, "No doctors found in Database", "Add a doctor in Firebase Console");
                  }

                  // 4. Transform to Map and inject Document ID
                  final doctors = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {...data, 'id': doc.id};
                  }).toList();

                  // 5. Apply Search & Filtering
                  final filteredDoctors = doctors.where((doc) {
                    final name = doc['name']?.toString().toLowerCase() ?? '';
                    final spec = doc['specialty']?.toString().toLowerCase() ?? '';
                    final searchQ = _searchController.text.toLowerCase();

                    final matchesSearch = _searchController.text.isEmpty ||
                        name.contains(searchQ) || spec.contains(searchQ);

                    final matchesFilter = _selectedFilter == 0 ||
                        _matchesFilter(spec, _filters[_selectedFilter]);

                    return matchesSearch && matchesFilter;
                  }).toList();

                  // 6. Handle empty search results
                  if (filteredDoctors.isEmpty) {
                    return _buildEmptyState(cs, "No doctors found", "Try adjusting your search or filters");
                  }

                  // 7. Render List
                  return Column(
                    children: [
                      // Results count
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredDoctors.length} doctor${filteredDoctors.length == 1 ? '' : 's'} found',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDoctors[index];
                            return DoctorCard(
                              doctor: doc,
                              onTap: () => Navigator.push(
                                context,
                                PageTransitions.slideRight(
                                    DoctorProfileScreen(doctor: doc)),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                                .slideY(
                                begin: 0.06,
                                end: 0,
                                duration: 400.ms,
                                delay: (index * 80).ms,
                                curve: Curves.easeOut);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(String spec, String filter) {
    switch (filter) {
      case 'Cardiology':
        return spec.contains('cardio');
      case 'Dentist':
        return spec.contains('dentist');
      case 'Gynecologist':
        return spec.contains('gynecol');
      case 'ENT':
        return spec.contains('ent');
      case 'Psychiatrist':
        return spec.contains('psychiatr');
      case 'Pediatric':
        return spec.contains('pediatr');
      case 'Orthopedic':
        return spec.contains('ortho');
      case 'General':
        return spec.contains('general');
      default:
        return spec.contains(filter.toLowerCase());
    }
  }

  // Helper widget to keep the tree clean
  Widget _buildEmptyState(ColorScheme cs, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}