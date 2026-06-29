// ────────────────────────────────────────────────────────
// بطاقة الروشتة المرتبطة بالموعد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PrescriptionDrugItem {
  final String name;
  final String dosage;

  const PrescriptionDrugItem({required this.name, required this.dosage});
}

class LinkedPrescriptionCard extends StatelessWidget {
  final bool hasPrescription;
  final String? diagnosis;
  final String? appointmentId;

  const LinkedPrescriptionCard({
    super.key,
    required this.hasPrescription,
    this.diagnosis,
    this.appointmentId,
  });

  List<PrescriptionDrugItem> get _mockDrugs {
    if (!hasPrescription) return [];
    return const [
      PrescriptionDrugItem(
        name: 'Amoxicillin 500mg',
        dosage: 'حبة كل 8 ساعات - لمدة 5 أيام',
      ),
      PrescriptionDrugItem(
        name: 'Panadol Extra',
        dosage: 'عند اللزوم',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border),
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
              const Icon(Icons.medication_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الروشتة الطبية',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (hasPrescription)
                TextButton(
                  onPressed: () {
                    if (appointmentId != null) {
                      context.push('/prescription/edit/$appointmentId');
                    }
                  },
                  child: Text(
                    'تعديل',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primaryContainer,
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
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
            ],
            ..._mockDrugs.map((drug) => Padding(
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم تفعيل الطباعة لاحقاً')),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('طباعة الروشتة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                backgroundColor: AppColors.primaryLight,
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
                  'لم تُصدر روشتة بعد',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    if (appointmentId != null) {
                      context.push('/prescription/$appointmentId');
                    }
                  },
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: const Text('إصدار روشتة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
