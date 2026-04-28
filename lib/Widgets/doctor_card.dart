import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'vitalis_card.dart';

/// Reusable doctor card used on home dashboard and doctor listings.
class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onTap;
  final bool showBookButton;

  const DoctorCard({super.key, required this.doctor, this.onTap, this.showBookButton = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.primary.withAlpha(51), width: 2)),
                child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(doctor['image']), backgroundColor: colors.inputFill),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(doctor['name'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: colors.textPrimary), overflow: TextOverflow.ellipsis)),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, color: colors.accent, size: 18),
                          const SizedBox(width: 2),
                          Text('${doctor['rating']}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.textPrimary)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(doctor['specialty'], style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: colors.success.withAlpha(26), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                        child: Text('Verified', style: TextStyle(color: colors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(doctor['experience'], style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          if (showBookButton) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: colors.inputFill, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, size: 16, color: colors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Text('Next Available: Today, 2:30 PM', style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onTap, child: const Text('Book Consultation'))),
          ],
        ],
      ),
    );
  }
}
