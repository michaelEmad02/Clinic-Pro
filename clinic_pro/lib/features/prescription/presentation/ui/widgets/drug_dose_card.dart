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
    String? doseOption,
    String? doseFrequency,
    String? doseDuration,
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

  static const List<String> _doseOptions = ['١ قرص', '٢ قرص', '٥ مل', '١٠ مل'];
  static const List<String> _frequencies = ['كل ١٢ ساعة', '٣ مرات يومياً', 'عند اللزوم', 'مرة واحدة'];
  static const List<String> _durations = ['٣ أيام', '٧ أيام', 'أسبوعين', 'مستمر'];
  static const List<String> _timings = ['قبل الأكل', 'بعد الأكل مباشرة', 'مع الأكل', 'أي وقت'];

  @override
  Widget build(BuildContext context) {
    // إذا كان عند اللزوم (PRN) فيتم إخفاء خيار المدة
    final isPrn = drug.doseFrequency == 'عند اللزوم' || drug.isPrn;

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

          // خيارات الجرعة والتكرار والمدة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRowTitle(context, 'الجرعة'),
                const SizedBox(height: 6),
                DoseChipSelector(
                  options: _doseOptions,
                  selectedOption: drug.doseOption,
                  onSelected: (val) => onUpdate(doseOption: val),
                ),
                const SizedBox(height: 12),

                _buildRowTitle(context, 'التكرار'),
                const SizedBox(height: 6),
                DoseChipSelector(
                  options: _frequencies,
                  selectedOption: drug.doseFrequency,
                  onSelected: (val) {
                    final prn = val == 'عند اللزوم';
                    onUpdate(
                      doseFrequency: val,
                      isPrn: prn,
                      doseDuration: prn ? 'مستمر' : null,
                    );
                  },
                ),

                if (!isPrn) ...[
                  const SizedBox(height: 12),
                  _buildRowTitle(context, 'المدة'),
                  const SizedBox(height: 6),
                  DoseChipSelector(
                    options: _durations,
                    selectedOption: drug.doseDuration,
                    onSelected: (val) => onUpdate(doseDuration: val),
                  ),
                ],
              ],
            ),
          ),

          // شريط التوقيت بالأسفل
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      drug.doseTiming,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  child: Row(
                    children: [
                      Text(
                        'تغيير التوقيت',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                    ],
                  ),
                  onSelected: (val) => onUpdate(doseTiming: val),
                  itemBuilder: (context) {
                    return _timings.map((t) {
                      return PopupMenuItem(
                        value: t,
                        child: Text(t),
                      );
                    }).toList();
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
