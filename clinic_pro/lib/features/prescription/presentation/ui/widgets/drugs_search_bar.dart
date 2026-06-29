import 'package:flutter/material.dart';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
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
          hintText: 'ابحث عن دواء باسمه العلمي أو التجاري...',
          hintStyle: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
