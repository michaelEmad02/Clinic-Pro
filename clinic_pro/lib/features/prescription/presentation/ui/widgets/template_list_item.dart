import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

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
    final name = template['name'] ?? '';
    final category = template['category'] ?? ''; // Category isn't in DB, kept for UI fallback if needed
    final useCount = template['user_count'] ?? 0;
    
    final items = template['items'] as List<dynamic>? ?? [];
    final drugCount = items.length;

    // تحديد لون جانبي مختلف بناء على الفئة لإضفاء جمالية
    Color sideColor = AppColors.primary;
    if (category == 'أمراض مزمنة') {
      sideColor = AppColors.accent;
    } else if (category == 'حالات حادة') {
      sideColor = const Color(0xFFF5A623); // Warning color
    }

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: sideColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والزر
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.textHint),
                    onPressed: onMoreTap,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              // الإحصائيات بالأسفل
              Row(
                children: [
                  // عدد الأدوية
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medication_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$drugCount أدوية',
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // عدد مرات الاستخدام
                  Row(
                    children: [
                      const Icon(Icons.history, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'استخدام: $useCount',
                        style: AppTextStyles.caption(context).copyWith(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
