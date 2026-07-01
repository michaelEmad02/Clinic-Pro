import 'package:clinic_pro/core/constants/prescription_enums.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/dose_chip_selector.dart';
import '../../manager/prescription_state.dart';

// ────────────────────────────────────────────────────────
// بطاقة الدواء في الروشتة: تتحكم بالجرعة والتكرار والمدة والتوقيت
// ────────────────────────────────────────────────────────

class DrugDoseCard extends StatelessWidget {
  final SelectedDrugModel drug;
  final Function({
    int? doseFrequency,
    int? doseDuration,
    String? doseTiming,
    bool? isPrn,
  }) onUpdate;
  final VoidCallback onRemove;

  const DrugDoseCard({
    super.key,
    required this.drug,
    required this.onUpdate,
    required this.onRemove,
  });



  @override
  Widget build(BuildContext context) {
    final isPrn = drug.isPrn;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          // رأس الكارت: اسم الدواء وزر الحذف
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.medication, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.tradeName,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        drug.genericName,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // خيارات التكرار والمدة والتوقيت
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر التبديل PRN
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRowTitle(context, 'عند اللزوم (PRN)'),
                    Switch(
                      value: isPrn,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        onUpdate(isPrn: val, doseFrequency: val ? null : 2, doseDuration: val ? null : 7);
                      },
                    ),
                  ],
                ),
                
                if (!isPrn) ...[
                  const SizedBox(height: 6),
                  _buildRowTitle(context, 'التكرار'),
                  const SizedBox(height: 6),
                  DoseChipSelector(
                    options: DrugFrequency.values.map((e) => e.label).toList(),
                    selectedOption: DrugFrequency.fromDbValue(drug.doseFrequency)?.label,
                    onSelected: (val) {
                      final freq = DrugFrequency.values.firstWhere((e) => e.label == val);
                      onUpdate(doseFrequency: freq.dbValue);
                    },
                  ),

                  const SizedBox(height: 12),
                  _buildRowTitle(context, 'المدة'),
                  const SizedBox(height: 6),
                  DoseChipSelector(
                    options: DrugDuration.values.map((e) => e.label).toList(),
                    selectedOption: DrugDuration.fromDbValue(drug.doseDuration)?.label,
                    onSelected: (val) {
                      final dur = DrugDuration.values.firstWhere((e) => e.label == val);
                      onUpdate(doseDuration: dur.dbValue);
                    },
                  ),
                ],

                const SizedBox(height: 12),
                _buildRowTitle(context, 'التوقيت'),
                const SizedBox(height: 6),
                DoseChipSelector(
                  options: DrugTiming.values.map((e) => e.label).toList(),
                  selectedOption: DrugTiming.fromDbValue(drug.doseTiming)?.label,
                  onSelected: (val) {
                    final timing = DrugTiming.values.firstWhere((e) => e.label == val);
                    onUpdate(doseTiming: timing.dbValue);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowTitle(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.caption(context).copyWith(
        color: AppColors.textHint,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
