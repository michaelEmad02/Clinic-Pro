// ────────────────────────────────────────────────────────
// شبكة الإحصائيات السريعة Bento — 2×2 جوال، 4 أعمدة سطح مكتب
// بطاقة التقييم بلون مختلف (primary-container)
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/clinics_state.dart';

class ClinicSummaryCards extends StatelessWidget {
  final ClinicItem clinic;

  const ClinicSummaryCards({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: AppConstants.spaceSm,
          mainAxisSpacing: AppConstants.spaceSm,
          childAspectRatio: 1.3,
          children: [
            _SummaryCard(
              icon: Icons.event,
              iconBg: AppColors.warningBg,
              iconColor: AppColors.warningText,
              value: _formatNumber(clinic.todayAppointments),
              label: AppStrings.todayAppointments,
              change: AppStrings.remainingAppointments(clinic.todayRemaining),
              changeColor: AppColors.textSecondary,
            ),
            _SummaryCard(
              icon: Icons.medical_services_outlined,
              iconBg: AppColors.primaryLight,
              iconColor: AppColors.primary,
              value: '${clinic.doctorsCount}',
              label: AppStrings.doctors,
              change: clinic.doctorsCount > 0 && clinic.doctorsOnLeave > 0
                  ? AppStrings.onLeave(clinic.doctorsOnLeave)
                  : clinic.doctorsCount > 0
                      ? AppStrings.active
                      : AppStrings.none,
              changeColor: AppColors.textSecondary,
            ),
            _SummaryCard(
              icon: Icons.payments_outlined,
              iconBg: AppColors.successBg,
              iconColor: AppColors.successText,
              value: '${_formatNumber(clinic.monthlyRevenue.toInt())} ${AppStrings.egp}',
              label: AppStrings.monthlyRevenue,
              change: AppStrings.active,
              changeColor: AppColors.successText,
            ),
            _SummaryCard(
              icon: Icons.check_circle_outline,
              iconBg: AppColors.primaryLight,
              iconColor: AppColors.primary,
              value: '${clinic.todayAppointments - clinic.todayRemaining}',
              label: AppStrings.completedAppointments,
              change: AppStrings.today,
              changeColor: AppColors.textSecondary,
            ),
          ],
        );
      },
    );
  }
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String change;
  final Color changeColor;

  const _SummaryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.change,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spaceSm + AppConstants.spaceXs),
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
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceXs),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, size: AppConstants.iconSizeMd, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 12,
                color: changeColor,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  change,
                  style: AppTextStyles.caption(context).copyWith(
                    color: changeColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const _RatingCard({
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spaceSm + AppConstants.spaceXs),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -12,
            right: -12,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceTint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.overallRating,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceXs),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: const Icon(Icons.star,
                        size: AppConstants.iconSizeMd, color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppStrings.outOfFive,
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                AppStrings.reviewCount(totalReviews),
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
