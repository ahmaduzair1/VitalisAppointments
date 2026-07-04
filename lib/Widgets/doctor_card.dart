import 'package:flutter/material.dart';
import 'vitalis_card.dart';

/// Premium doctor card with avatar, specialty, rating, and availability.
/// All fields are null-safe to handle incomplete Firebase documents.
class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onTap;
  final bool isCompact;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.isCompact = false,
  });

  // ── Safe accessors ──────────────────────────────────────
  String get _name => doctor['name'] as String? ?? 'Unknown Doctor';
  String get _specialty => doctor['specialty'] as String? ?? 'General';
  String get _image => doctor['image'] as String? ?? '';
  String get _rating => (doctor['rating'] ?? 0.0).toString();
  String get _reviews => (doctor['reviews'] ?? '0').toString();
  String get _fee => (doctor['fee'] ?? 0).toString();
  bool get _isAvailable => doctor['availableToday'] == true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (isCompact) {
      return _buildCompactCard(context, theme, cs);
    }
    return _buildFullCard(context, theme, cs);
  }

  /// Builds either a NetworkImage or a fallback icon for missing images.
  Widget _buildAvatarImage(ColorScheme cs, double size, double radius) {
    if (_image.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: cs.onSurfaceVariant.withValues(alpha: 0.08),
          image: DecorationImage(
            image: NetworkImage(_image),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    // Fallback: icon placeholder
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: cs.primary.withValues(alpha: 0.1),
      ),
      child: Icon(Icons.person_rounded,
          size: size * 0.5, color: cs.primary.withValues(alpha: 0.6)),
    );
  }

  /// Horizontal scrolling compact card (for "Top Doctors" row).
  Widget _buildCompactCard(
      BuildContext context, ThemeData theme, ColorScheme cs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: theme.brightness == Brightness.dark
              ? Border.all(color: cs.outline.withValues(alpha: 0.3))
              : null,
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'doctor_avatar_$_name',
                  child: _buildAvatarImage(cs, 80, 24),
                ),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: 14),
                        const SizedBox(width: 2),
                        Text(
                          _rating,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _specialty,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Rating moved to avatar
          ],
        ),
      ),
    );
  }

  /// Full-width list card (for "Available Today" / Doctor List).
  Widget _buildFullCard(
      BuildContext context, ThemeData theme, ColorScheme cs) {
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: 'doctor_avatar_$_name',
                child: _image.isNotEmpty
                    ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          color: cs.onSurfaceVariant.withValues(alpha: 0.08),
                          image: DecorationImage(
                            image: NetworkImage(_image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          color: cs.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.person_rounded,
                            size: 40,
                            color: cs.primary.withValues(alpha: 0.6)),
                      ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        _rating,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isAvailable
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : cs.onSurfaceVariant.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _isAvailable
                              ? const Color(0xFF10B981)
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _specialty,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$_reviews Reviews',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$$_fee',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
