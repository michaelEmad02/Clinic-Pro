// ────────────────────────────────────────────────────────
// أداء الأطباء — صورة + اسم + عدد مرضى + نسبة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/reports_state.dart';

class DoctorPerformanceList extends StatelessWidget {
  final List<DoctorPerformanceItem> doctors;

  const DoctorPerformanceList({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أداء الأطباء',
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...doctors.map((doctor) => _DoctorRow(doctor: doctor)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'عـرض الـكـل',
                style: AppTextStyles.labelChip(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  final DoctorPerformanceItem doctor;

  const _DoctorRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: doctor.avatarUrl != null
                ? NetworkImage(doctor.avatarUrl!)
                : null,
            child: doctor.avatarUrl == null
                ? Text(
                    doctor.doctorName.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.doctorName,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${doctor.patientCount} مريض',
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${doctor.rating}%',
                style: AppTextStyles.dataNumeric(context).copyWith(
                  color: doctor.trend == 'up'
                      ? AppColors.successText
                      : doctor.trend == 'down'
                          ? AppColors.dangerText
                          : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                doctor.trend == 'up'
                    ? Icons.arrow_upward
                    : doctor.trend == 'down'
                        ? Icons.arrow_downward
                        : Icons.horizontal_rule,
                size: 14,
                color: doctor.trend == 'up'
                    ? AppColors.successText
                    : doctor.trend == 'down'
                        ? AppColors.dangerText
                        : AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
