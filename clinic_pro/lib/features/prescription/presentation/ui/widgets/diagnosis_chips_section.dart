import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/templates_cubit.dart';
import '../../manager/templates_state.dart';

// ────────────────────────────────────────────────────────
// قسم رقاقات التشخيص: يعرض التشخيصات المختارة والشائعة
// يستخدم TemplatesCubit لجلب قوالب التشخيصات
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check, color: context.primary),
              const SizedBox(width: 8),
              Text(
                AppStrings.medicalDiagnosis,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
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
                    hintText: AppStrings.diagnosisHint,
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textHint,
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
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppStrings.add),
              ),
            ],
          ),
          const SizedBox(height: 16),

          BlocBuilder<TemplatesCubit, TemplatesState>(
            builder: (context, state) {
              final List<Map<String, dynamic>> templates =
                  state is TemplatesLoaded ? state.templates : [];

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // التشخيصات المختارة حالياً
                  ...widget.selectedDiagnosis.map((diag) {
                    return Chip(
                      label: Text(
                        diag,
                        style: AppTextStyles.labelChip(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: context.primaryLightColor,
                      side: BorderSide(color: context.primary, width: 0.5),
                      deleteIcon:
                          Icon(Icons.close, size: 14, color: context.primary),
                      onDeleted: () => widget.onToggleDiagnosis(diag),
                    );
                  }),
                  // قوالب التشخيصات الشائعة غير المختارة بعد
                  ...templates.where((t) {
                    final String name = t['name'] ?? '';
                    return name.isNotEmpty &&
                        !widget.selectedDiagnosis.contains(name);
                  }).map((t) {
                    final String name = t['name'] ?? '';
                    return ActionChip(
                      label: Text(
                        name,
                        style: AppTextStyles.labelChip(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      backgroundColor: context.surfaceBright,
                      side: BorderSide.none,
                      onPressed: () => widget.onToggleDiagnosis(name),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
