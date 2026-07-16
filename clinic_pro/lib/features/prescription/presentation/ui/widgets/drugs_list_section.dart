import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/prescription_state.dart';
import 'drug_dose_card.dart';

// ────────────────────────────────────────────────────────
// قسم قائمة الأدوية المختارة في الروشتة + زر إضافة دواء
// ────────────────────────────────────────────────────────

class DrugsListSection extends StatelessWidget {
  final List<SelectedDrugModel> selectedDrugs;
  final Function(String,
      {int? doseFrequency,
      int? doseDuration,
      String? doseTiming,
      bool? isPrn}) onUpdateDrug;
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
              Icon(Icons.medication_outlined, color: context.primary),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.prescription} (${AppStrings.drugs})',
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
              onUpdate: ({doseFrequency, doseDuration, doseTiming, isPrn}) {
                onUpdateDrug(
                  drug.id,
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
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.primaryLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: context.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.addDrug,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.search} ${AppStrings.drugBase}',
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
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
