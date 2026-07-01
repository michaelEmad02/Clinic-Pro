import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// حوار معاينة القالب مع قائمة الأدوية المشمولة
// ────────────────────────────────────────────────────────

class TemplatePreviewDialog extends StatelessWidget {
  final Map<String, dynamic> template;
  final Function(List<Map<String, dynamic>>)? onApply;

  const TemplatePreviewDialog({
    super.key,
    required this.template,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final drugsInTemplate = template['items'] as List<dynamic>? ?? [];

    return AlertDialog(
      title: Text(
        'معاينة: ${template['name'] ?? ''}',
        style: AppTextStyles.headlineSmall(context).copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: drugsInTemplate.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('لا توجد أدوية مضافة في هذا القالب بعد.'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: drugsInTemplate.length,
                itemBuilder: (context, index) {
                  final item = drugsInTemplate[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['trade_name'] ?? '',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${item['frequency'] ?? ''} - ${item['duration'] ?? ''} أيام - ${item['timing'] ?? ''}',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
        if (onApply != null && drugsInTemplate.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onApply!(drugsInTemplate.cast<Map<String, dynamic>>());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('تطبيق القالب'),
          ),
      ],
    );
  }
}
