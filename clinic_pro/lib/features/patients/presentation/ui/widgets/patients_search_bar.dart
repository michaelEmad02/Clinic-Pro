// ────────────────────────────────────────────────────────
// شريط البحث في قائمة المرضى — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PatientsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const PatientsSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: AppStrings.searchByName,
          hintStyle: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textHint,
          ),
          prefixIcon: Icon(Icons.search, color: context.textSecondary),
          filled: true,
          fillColor: context.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            borderSide: BorderSide(color: context.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            borderSide: BorderSide(color: context.border),
          ),
        ),
      ),
    );
  }
}
