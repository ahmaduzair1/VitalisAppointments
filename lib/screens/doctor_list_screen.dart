import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/page_transitions.dart';
import '../core/mock_data.dart';
import '../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _searchController = TextEditingController();
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Cardiology', 'Dermatology', 'Neurology', 'Orthopedic', 'Pediatric'];

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_selectedFilter == 0 && _searchController.text.isEmpty) {
      return MockData.doctors;
    }

    return MockData.doctors.where((doc) {
      final matchesSearch = _searchController.text.isEmpty ||
          doc['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          doc['specialty'].toString().toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesFilter = _selectedFilter == 0 ||
          doc['specialty'].toString().toLowerCase().contains(_filters[_selectedFilter].toLowerCase());

      return matchesSearch && matchesFilter;
    }).toList();
  }

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
      appBar: AppBar(
        title: const Text('Find Doctors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: cs.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty...',
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
                              : cs.onSurface.withOpacity(0.04),
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

          // ── Results count ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredDoctors.length} doctor${_filteredDoctors.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Doctor list ───────────────────────────────
          Expanded(
            child: _filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: cs.onSurfaceVariant.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = _filteredDoctors[index];
                      return DoctorCard(
                        doctor: doc,
                        onTap: () => Navigator.push(
                          context,
                          PageTransitions.slideRight(
                              DoctorProfileScreen(doctor: doc)),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: 400.ms, delay: (index * 80).ms)
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
      ),
    );
  }
}
