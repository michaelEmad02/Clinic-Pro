import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ClinicPerformanceChart extends StatelessWidget {
  const ClinicPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    // شهور المحاكاة وقيم الأداء المقابلة لها
    final monthValues = <double>[15000, 22000, 18000, 31000, 28000];
    final performanceData = List.generate(
      monthValues.length,
      (i) => (AppStrings.shortMonths[i], monthValues[i]),
    );

    final maxVal = performanceData.fold<double>(
        0.0, (max, item) => item.$2 > max ? item.$2 : max);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: AppColors.border),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.clinicPerformance,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.bar_chart_outlined,
                  color: AppColors.primary, size: AppConstants.iconSizeXl),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLg),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: performanceData.map((data) {
                final monthName = data.$1;
                final value = data.$2;
                final percentage = maxVal > 0 ? value / maxVal : 0.0;
                final barHeight =
                    percentage * 120; // الحد الأقصى لطول العمود 120 بكسل

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(value / 1000).toStringAsFixed(0)}k',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: barHeight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.darkPrimaryLight
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      monthName,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
