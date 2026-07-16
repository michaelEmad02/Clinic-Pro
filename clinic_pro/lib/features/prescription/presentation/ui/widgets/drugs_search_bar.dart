import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
