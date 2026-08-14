import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class TopDiagnosesWidget extends StatefulWidget {
  final List<NameCountStatEntity> diagnoses;

  const TopDiagnosesWidget({super.key, required this.diagnoses});

  @override
  State<TopDiagnosesWidget> createState() => _TopDiagnosesWidgetState();
}

class _TopDiagnosesWidgetState extends State<TopDiagnosesWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.diagnoses.isEmpty) return const SizedBox.shrink();

    final top10 = widget.diagnoses.take(10).toList();
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
                'أكثر التشخيصات شيوعاً بالعيادة',
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
          const SizedBox(height: AppConstants.spaceMd),
          ...visibleItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 16, color: context.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${item.count} حالة (${item.percentage.toStringAsFixed(1)}%)',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (item.percentage / 50).clamp(0.0, 1.0),
                      backgroundColor: context.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                      minHeight: 4,
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
