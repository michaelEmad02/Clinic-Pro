import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class TemplateUsageWidget extends StatefulWidget {
  final List<TemplateStatsEntity> templates;

  const TemplateUsageWidget({super.key, required this.templates});

  @override
  State<TemplateUsageWidget> createState() => _TemplateUsageWidgetState();
}

class _TemplateUsageWidgetState extends State<TemplateUsageWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.templates.isEmpty) return const SizedBox.shrink();

    final top10 = widget.templates.take(10).toList();
    final visibleItems = _isExpanded ? top10 : top10.take(5).toList();
    final canExpand = top10.length > 5;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تحليل استخدام قوالب الروشتات',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              if (canExpand)
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'عرض أقل' : 'عرض الكل (${top10.length})',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: context.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'معرفة القوالب الأكثر والأقل استخداماً لتحسين سير العمل',
            style: AppTextStyles.caption(context).copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          ...visibleItems.map((tmpl) {
            final isUnused = tmpl.userCount == 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isUnused ? Icons.history_toggle_off_rounded : Icons.bookmark_added_rounded,
                    size: 18,
                    color: isUnused ? context.textSecondary : const Color(0xFF2ECC9A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tmpl.name,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnused ? context.textSecondary : context.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnused
                          ? context.borderColor.withOpacity(0.3)
                          : const Color(0xFF2ECC9A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUnused ? 'غير مستخدم' : '${tmpl.userCount} استخدام (${tmpl.percentage.toStringAsFixed(0)}%)',
                      style: AppTextStyles.caption(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnused ? context.textSecondary : const Color(0xFF2ECC9A),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
