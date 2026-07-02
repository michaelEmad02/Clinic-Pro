// ────────────────────────────────────────────────────────
// قسم ساعات العمل — أيام الأسبوع مع تمييز اليوم الحالي
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ClinicWorkingHoursSection extends StatelessWidget {
  final String clinicId;

  const ClinicWorkingHoursSection({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    final hours = MockData.clinicWorkingHours
        .where((h) => h['clinic_id'] == clinicId)
        .toList();

    if (hours.isEmpty) return const SizedBox.shrink();

    final hourData = hours.first;

    // اليوم الحالي (0=أحد .. 6=سبت)
    final todayIndex = DateTime.now().weekday % 7;

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
            children: [
              const Icon(Icons.schedule,
                  size: AppConstants.iconSizeLg, color: AppColors.primary),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                AppStrings.workingHours,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppConstants.spaceSm),
          ...List.generate(7, (index) {
            final day = AppStrings.dayNames[index];
            final time = hourData[AppStrings.dayKeys[index]] as String? ??
                AppStrings.closed;
            final isClosed = time == AppStrings.closed;
            final isToday = index == todayIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                padding: isToday
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Row(
                        children: [
                          Text(
                            day,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppColors.primary
                                  : isClosed
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday)
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 4),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        time,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: isClosed
                              ? AppColors.textHint
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    if (isClosed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          AppStrings.closed,
                          style: AppTextStyles.labelChip(context).copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
