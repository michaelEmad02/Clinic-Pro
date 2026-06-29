import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class CurrentPlanCard extends StatelessWidget {
  final String planType;
  final String planStatus;

  const CurrentPlanCard({super.key, this.planType = 'الباقة الأساسية', this.planStatus = 'تجربة مجانية'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(planType, style: AppTextStyles.headlineMedium(context)),
              const SizedBox(width: AppConstants.spaceSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('تجربة مجانية', style: AppTextStyles.labelChip(context).copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text('مثالية للعيادات الناشئة والممارسين المستقلين.',
              style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('0', style: AppTextStyles.headlineLarge(context).copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 32,
              )),
              const SizedBox(width: 4),
              Text('ريال / شهرياً', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
