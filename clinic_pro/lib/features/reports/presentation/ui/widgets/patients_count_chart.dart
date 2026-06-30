// ────────────────────────────────────────────────────────
// رسم بياني بعدد المرضى لكل طبيب (محاكاة)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/reports_state.dart';

class PatientsCountChart extends StatelessWidget {
  final List<DoctorPerformanceItem> doctors;

  const PatientsCountChart({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    final maxPatients = doctors.fold<int>(
        0, (max, d) => d.patientCount > max ? d.patientCount : max);

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
            'عدد المرضى لكل طبيب',
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...doctors.map((doctor) {
            final ratio = maxPatients > 0
                ? doctor.patientCount / maxPatients
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doctor.doctorName,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${doctor.patientCount}',
                        style: AppTextStyles.dataNumeric(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.primaryLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
