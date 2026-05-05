import 'package:flutter/material.dart';
import 'vitalis_card.dart';

/// Premium doctor card with avatar, specialty, rating, and availability.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (isCompact) {
      return _buildCompactCard(context, theme, cs);
    }
    return _buildFullCard(context, theme, cs);
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
          borderRadius: BorderRadius.circular(16),
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
            Hero(
              tag: 'doctor_avatar_${doctor['name']}',
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(doctor['image']),
                backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.08),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              doctor['name'],
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
              doctor['specialty'],
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${doctor['rating']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Full-width list card (for "Available Today" / Doctor List).
  Widget _buildFullCard(
      BuildContext context, ThemeData theme, ColorScheme cs) {
    final bool isAvailable = doctor['availableToday'] == true;

    return VitalisCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          Hero(
            tag: 'doctor_avatar_${doctor['name']}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(doctor['image']),
                backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.08),
              ),
            ),
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
                        doctor['name'],
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
                        color: isAvailable
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : cs.onSurfaceVariant.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? const Color(0xFF10B981)
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  doctor['specialty'],
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: const Color(0xFFFBBF24), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor['rating']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${doctor['reviews']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${doctor['fee']}',
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
