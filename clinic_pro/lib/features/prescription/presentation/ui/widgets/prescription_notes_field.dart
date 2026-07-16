import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// حقول التشخيص النهائي والملاحظات الإضافية
// ────────────────────────────────────────────────────────

class PrescriptionNotesField extends StatelessWidget {
  final String finalDiagnosis;
  final String notes;
  final ValueChanged<String> onFinalDiagnosisChanged;
  final ValueChanged<String> onNotesChanged;

  const PrescriptionNotesField({
    super.key,
    required this.finalDiagnosis,
    required this.notes,
    required this.onFinalDiagnosisChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.diagnosis,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: finalDiagnosis,
            onChanged: onFinalDiagnosisChanged,
            maxLines: 3,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: AppStrings.diagnosisHint,
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textHint,
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.notes,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: notes,
            onChanged: onNotesChanged,
            maxLines: 3,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: AppStrings.notes,
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textHint,
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: context.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
