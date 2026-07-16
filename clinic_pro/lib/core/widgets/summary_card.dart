import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../constants/app_constants.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? trend;
  final bool isPositiveTrend;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? context.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppConstants.spaceXs),
            Row(
              children: [
                Icon(
                  isPositiveTrend ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositiveTrend ? context.accent : context.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: AppTextStyles.caption(context).copyWith(
                    color: isPositiveTrend ? context.accent : context.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
