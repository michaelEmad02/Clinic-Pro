// ────────────────────────────────────────────────────────
// زر استدعاء المريض التالي في الطابور
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class CallNextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const CallNextButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.volume_up_outlined),
        label: Text(
          AppStrings.callNext,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.white : AppColors.textHint,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
