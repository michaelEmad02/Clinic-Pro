import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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
        '${AppStrings.prescription}: ${template['name'] ?? ''}',
        style: AppTextStyles.headlineSmall(context).copyWith(
          fontWeight: FontWeight.bold,
          color: context.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: drugsInTemplate.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(AppStrings.noDrugs),
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
                      '${item['frequency'] ?? ''} - ${item['duration'] ?? ''} - ${item['timing'] ?? ''}',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.close),
        ),
        if (onApply != null && drugsInTemplate.isNotEmpty)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onApply!(drugsInTemplate.cast<Map<String, dynamic>>());
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.primary),
            child: Text(AppStrings.addTemplate),
          ),
      ],
    );
  }
}
