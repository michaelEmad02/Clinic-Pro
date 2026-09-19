// ────────────────────────────────────────────────────────
// حقل إدخال التشخيص الطبي في الروشتة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PrescriptionDiagnosisField extends StatefulWidget {
  final String finalDiagnosis;
  final ValueChanged<String> onFinalDiagnosisChanged;

  const PrescriptionDiagnosisField({
    super.key,
    required this.finalDiagnosis,
    required this.onFinalDiagnosisChanged,
  });

  @override
  State<PrescriptionDiagnosisField> createState() =>
      _PrescriptionDiagnosisFieldState();
}

class _PrescriptionDiagnosisFieldState
    extends State<PrescriptionDiagnosisField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.finalDiagnosis);
  }

  @override
  void didUpdateWidget(covariant PrescriptionDiagnosisField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.finalDiagnosis != oldWidget.finalDiagnosis &&
        widget.finalDiagnosis != _controller.text) {
      _controller.text = widget.finalDiagnosis;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                size: 20,
                color: context.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.diagnosis,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller,
            onChanged: widget.onFinalDiagnosisChanged,
            maxLines: 2,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: AppStrings.diagnosisHint,
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textHint,
              ),
              filled: true,
              fillColor: context.surfaceColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                borderSide: BorderSide(color: context.borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
