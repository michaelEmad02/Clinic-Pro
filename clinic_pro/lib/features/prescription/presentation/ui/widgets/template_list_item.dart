import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// عنصر قائمة قالب الروشتة في شاشة القوالب
// ────────────────────────────────────────────────────────

class TemplateListItem extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const TemplateListItem({
    super.key,
    required this.template,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = template['title'] ?? '';
    final category = template['category'] ?? '';
    final useCount = template['use_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.assignment_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.headlineSmall(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.labelChip(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'استخدام: $useCount مرة',
                style: AppTextStyles.caption(context).copyWith(
                  fontFamily: 'Inter',
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onTap,
              child: const Text('معاينة'),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
