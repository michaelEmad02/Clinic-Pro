import 'package:flutter/material.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// قسم رقاقات التشخيص: يعرض التشخيصات المختارة والشائعة
// ────────────────────────────────────────────────────────

class DiagnosisChipsSection extends StatefulWidget {
  final List<String> selectedDiagnosis;
  final ValueChanged<String> onToggleDiagnosis;
  final ValueChanged<String> onAddCustomDiagnosis;

  const DiagnosisChipsSection({
    super.key,
    required this.selectedDiagnosis,
    required this.onToggleDiagnosis,
    required this.onAddCustomDiagnosis,
  });

  @override
  State<DiagnosisChipsSection> createState() => _DiagnosisChipsSectionState();
}

class _DiagnosisChipsSectionState extends State<DiagnosisChipsSection> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = MockData.diagnosisTemplates;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'التشخيص الطبي',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // حقل البحث/الإضافة السريعة للتشخيص المخصص
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  style: AppTextStyles.bodyMedium(context),
                  decoration: InputDecoration(
                    hintText: 'أدخل تشخيص مخصص للزيارة الحالية...',
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.textHint,
                    ),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_customController.text.trim().isNotEmpty) {
                    widget.onAddCustomDiagnosis(_customController.text.trim());
                    _customController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // رقاقات التشخيصات الشائعة والمختارة
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // التشخيصات المختارة حالياً
              ...widget.selectedDiagnosis.map((diag) {
                return Chip(
                  label: Text(
                    diag,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primaryLight,
                  side: const BorderSide(color: AppColors.primary, width: 0.5),
                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.primary),
                  onDeleted: () => widget.onToggleDiagnosis(diag),
                );
              }),
              // قوالب التشخيصات الشائعة غير المختارة بعد
              ...templates
                  .where((t) => !widget.selectedDiagnosis.contains(t['title']))
                  .map((t) {
                final String title = t['title'] ?? '';
                return ActionChip(
                  label: Text(
                    title,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  backgroundColor: AppColors.surfaceAlt,
                  side: BorderSide.none,
                  onPressed: () => widget.onToggleDiagnosis(title),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
