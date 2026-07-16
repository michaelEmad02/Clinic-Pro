import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class SettingsOwnerSection extends StatelessWidget {
  final VoidCallback? onSubscriptionTap;

  const SettingsOwnerSection({super.key, this.onSubscriptionTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text(AppStrings.management, style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onSubscriptionTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
                  child: Row(
                    children: [
                      Icon(Icons.payments, color: AppColors.primaryContainer, size: 20),
                      const SizedBox(width: AppConstants.spaceSm),
                       Expanded(child: Text(AppStrings.subscriptionAndPlan, style: AppTextStyles.bodyLarge(context))),
                      const Icon(Icons.arrow_back, color: AppColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
