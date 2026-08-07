import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
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
    final useCount = template['user_count'] ?? 0;

    final items = template['items'] as List<dynamic>? ?? [];
    final drugCount = items.length;

    final int hash = name.hashCode;
    final List<Color> beautifulColors = [
      context.primary,
      context.accent,
      context.warning,
      context.success,
    ];
    final Color sideColor =
        beautifulColors[hash.abs() % beautifulColors.length];

    return Card(
      elevation: 0,
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        side: BorderSide(color: context.borderColor),
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
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            color: context.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: context.textHint),
                    onPressed: onMoreTap,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Divider(height: 1, color: context.borderColor),
              const SizedBox(height: AppConstants.spaceSm + 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceSm + 2,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medication_outlined,
                            size: AppConstants.iconSizeMd, color: context.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$drugCount ${AppStrings.drugs}',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm + 4),
                  Row(
                    children: [
                      Icon(Icons.history,
                          size: AppConstants.iconSizeMd, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '$useCount',
                        style: AppTextStyles.dataNumeric(context).copyWith(
                          color: context.textSecondary,
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
