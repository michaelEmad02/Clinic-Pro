import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/prescription_state.dart';
import 'drug_dose_card.dart';

// ────────────────────────────────────────────────────────
// قسم قائمة الأدوية المختارة في الروشتة + زر إضافة دواء
// ────────────────────────────────────────────────────────

class DrugsListSection extends StatelessWidget {
  final List<SelectedDrugModel> selectedDrugs;
  final Function(String, {String? doseOption, String? doseFrequency, String? doseDuration, String? doseTiming, bool? isPrn}) onUpdateDrug;
  final Function(String) onRemoveDrug;
  final VoidCallback onAddDrugTap;

  const DrugsListSection({
    super.key,
    required this.selectedDrugs,
    required this.onUpdateDrug,
    required this.onRemoveDrug,
    required this.onAddDrugTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.medication_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'الوصفة الطبية (الأدوية)',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // قائمة الأدوية المختارة
        if (selectedDrugs.isNotEmpty)
          ...selectedDrugs.map((drug) {
            return DrugDoseCard(
              drug: drug,
              onUpdate: ({doseOption, doseFrequency, doseDuration, doseTiming, isPrn}) {
                onUpdateDrug(
                  drug.id,
                  doseOption: doseOption,
                  doseFrequency: doseFrequency,
                  doseDuration: doseDuration,
                  doseTiming: doseTiming,
                  isPrn: isPrn,
                );
              },
              onRemove: () => onRemoveDrug(drug.id),
            );
          }),

        // زر إضافة دواء جديد (تصميم منقط)
        GestureDetector(
          onTap: onAddDrugTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'إضافة دواء للوصفة',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ابحث في قاعدة بيانات الأدوية أو استخدم النماذج المحفوظة مسبقاً',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
