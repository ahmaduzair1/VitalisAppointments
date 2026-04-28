import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_spacing.dart';
import 'vitalis_card.dart';

/// Reusable appointment card widget.
class AppointmentCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final Color statusColor;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return VitalisCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(radius: 22, backgroundColor: colors.inputFill, child: Icon(Icons.person_rounded, color: colors.textSecondary, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(specialty, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withAlpha(26), borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.inputFill, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 15, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(date, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.textPrimary), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.inputFill, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  child: Row(children: [
                    Icon(Icons.access_time_rounded, size: 15, color: colors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(time, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.textPrimary), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
