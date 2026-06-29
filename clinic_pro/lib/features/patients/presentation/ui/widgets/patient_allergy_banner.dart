// ────────────────────────────────────────────────────────
// بانر الحالة الصحية والحساسية — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/patients_state.dart';

class PatientAllergyBanner extends StatelessWidget {
  final PatientItem patient;

  const PatientAllergyBanner({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final hasChronic = patient.chronicConditions.isNotEmpty &&
        patient.chronicConditions != 'لا يوجد';
    final hasAllergies = patient.hasAllergies;

    if (!hasChronic && !hasAllergies) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.dangerBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                'الحالة الصحية',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.dangerText,
                ),
              ),
            ],
          ),
          if (hasChronic) ...[
            const SizedBox(height: 12),
            Text(
              'الأمراض المزمنة',
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              patient.chronicConditions,
              style: AppTextStyles.bodyMedium(context),
            ),
          ],
          if (hasAllergies) ...[
            const SizedBox(height: 12),
            Text(
              'الحساسية الدوائية',
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              patient.allergies,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.dangerText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
