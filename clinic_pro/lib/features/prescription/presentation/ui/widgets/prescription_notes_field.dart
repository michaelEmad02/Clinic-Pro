import 'package:flutter/material.dart';
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
            'التشخيص النهائي',
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
              hintText: 'اكتب التشخيص النهائي هنا...',
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textHint,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ملاحظات إضافية',
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
              hintText: 'تعليمات للمريض أو ملاحظات داخلية...',
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textHint,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
