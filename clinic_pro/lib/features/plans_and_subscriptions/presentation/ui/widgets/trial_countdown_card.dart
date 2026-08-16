import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class TrialCountdownCard extends StatelessWidget {
  final int daysRemaining;
  final bool isTrial;

  const TrialCountdownCard({
    super.key,
    this.daysRemaining = 5,
    this.isTrial = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.warningBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.warningText.withAlpha(50)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timer, color: context.warningText, size: 24),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.trialEndingSoon,
                  style: AppTextStyles.headlineSmall(context)
                      .copyWith(color: context.warningText),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.trialDesc,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(color: context.warningText.withAlpha(200)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceSm,
            ),
            decoration: BoxDecoration(
              color: context.warningBg,
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: context.warningBg),
            ),
            child: Column(
              children: [
                Text(
                  daysRemaining.toString().padLeft(2, '0'),
                  style: AppTextStyles.headlineLarge(context).copyWith(
                    color: context.warningText,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  AppStrings.daysRemaining,
                  style: AppTextStyles.caption(context)
                      .copyWith(color: context.warningText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpgradeCtaButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const UpgradeCtaButton({super.key, this.onPressed});

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
            color: Color(0x401A6B8A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.upgradeTitle,
            style: AppTextStyles.headlineMedium(context)
                .copyWith(color: context.onPrimary),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            AppStrings.upgradeDesc,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: context.onPrimaryContainer),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: Text(AppStrings.upgradeNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surfaceColor,
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
