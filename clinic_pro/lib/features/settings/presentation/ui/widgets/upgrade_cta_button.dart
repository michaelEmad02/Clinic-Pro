import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_text_styles.dart';

class UpgradeCtaButton extends StatelessWidget {
  const UpgradeCtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primaryContainer, context.primary],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: const [
          BoxShadow(
              color: Color(0x401A6B8A), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.upgradeTitle,
              style: AppTextStyles.headlineMedium(context)
                  .copyWith(color: context.onPrimary)),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
              AppStrings.upgradeDesc,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(color: context.onPrimaryContainer)),
          const SizedBox(height: AppConstants.spaceMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(RouteConstants.onboardingPlan);
              },
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: Text(AppStrings.upgradeNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surface,
                foregroundColor: context.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
