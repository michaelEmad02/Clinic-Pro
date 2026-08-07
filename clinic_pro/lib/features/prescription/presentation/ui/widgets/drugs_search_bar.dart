import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شريط بحث الأدوية المشترك بين شاشات الأدوية والقوالب
// ────────────────────────────────────────────────────────

class DrugsSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const DrugsSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium(context),
        decoration: InputDecoration(
          hintText: AppStrings.searchDrugs,
          hintStyle: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textHint,
          ),
          prefixIcon: Icon(Icons.search, color: context.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: AppConstants.spaceMd,
          ),
        ),
      ),
    );
  }
}
