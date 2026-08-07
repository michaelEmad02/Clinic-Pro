// ────────────────────────────────────────────────────────
// بطاقة الروشتة المرتبطة بالموعد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/appointment_entity.dart';

class PrescriptionDrugItem {
  final String name;
  final String dosage;

  const PrescriptionDrugItem({required this.name, required this.dosage});
}

class LinkedPrescriptionCard extends StatelessWidget {
  final bool hasPrescription;
  final String? diagnosis;
  final String? appointmentId;
  final AppointmentEntity? appointment;

  const LinkedPrescriptionCard({
    super.key,
    required this.hasPrescription,
    this.diagnosis,
    this.appointmentId,
    this.appointment,
  });

  List<PrescriptionDrugItem> get _realDrugs {
    if (!hasPrescription || appointment?.prescriptionDrugs == null) return [];
    
    return appointment!.prescriptionDrugs!.map((item) {
      final String name = item.drug?.tradeName ?? 'دواء غير معروف';
      
      final isPrn = item.isPrn;
      final frequency = item.frequency;
      final duration = item.duration;
      final timing = item.timing;
      
      String timingText = '';
      if (timing == 'before_meal') {
        timingText = AppStrings.isArabic ? 'قبل الأكل' : 'before meal';
      } else if (timing == 'after_meal') {
        timingText = AppStrings.isArabic ? 'بعد الأكل' : 'after meal';
      } else if (timing == 'with_meal') {
        timingText = AppStrings.isArabic ? 'مع الأكل' : 'with meal';
      }

      String dosage = '';
      if (isPrn) {
        dosage = AppStrings.isArabic ? 'عند اللزوم' : 'As needed';
      } else {
        final String freqText = frequency != null 
            ? (AppStrings.isArabic ? ' $frequency مرة' : 'every $frequency hours')
            : '';
        final String durText = duration != null
            ? (AppStrings.isArabic ? 'لمدة $duration يوم' : 'for $duration days')
            : '';
        
        final parts = [freqText, durText, timingText].where((p) => p.isNotEmpty).join(' - ');
        dosage = parts.isNotEmpty ? parts : (AppStrings.isArabic ? 'حسب إرشادات الطبيب' : 'As directed by physician');
      }

      return PrescriptionDrugItem(
        name: name,
        dosage: dosage,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.medication_outlined, color: context.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.prescriptionLabel,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
              ),
              if (hasPrescription)
                TextButton(
                  onPressed: () {
                    if (appointmentId != null) {
                      context.push('/prescription/edit/$appointmentId', extra: appointment);
                    }
                  },
                  child: Text(
                    AppStrings.edit,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPrescription) ...[
            if (diagnosis != null) ...[
              Text(
                diagnosis!,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ..._realDrugs.map((drug) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.name,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        drug.dosage,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.noData)),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 18),
              label: Text(AppStrings.printPrescription),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primary,
                side: BorderSide(color: context.primary.withOpacity(0.2)),
                backgroundColor: context.primaryLightColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
          ] else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.noPrescription,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (appointmentId != null) {
                      context.push('/prescription/$appointmentId', extra: appointment);
                    }
                  },
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: Text(AppStrings.newPrescription),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
