import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// عنصر قائمة الأدوية في شاشة إدارة الأدوية
// ────────────────────────────────────────────────────────

class DrugListItem extends StatelessWidget {
  final Map<String, dynamic> drug;
  final VoidCallback onTap;

  const DrugListItem({
    super.key,
    required this.drug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String tradeName = drug['trade_name'] ?? '';
    final String genericName = drug['generic_name'] ?? '';
    final String category = drug['category'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.primaryLightColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          child: Center(
            child: Icon(
              Icons.medication_outlined,
              color: context.primary,
              size: AppConstants.iconSizeXl,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tradeName,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceSm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Text(
                category,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              genericName,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: context.textSecondary),
          onPressed: onTap,
        ),
      ),
    );
  }
}
