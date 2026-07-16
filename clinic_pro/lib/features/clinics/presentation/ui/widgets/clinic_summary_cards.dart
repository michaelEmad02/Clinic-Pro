// ────────────────────────────────────────────────────────
// شبكة الإحصائيات السريعة Bento — 2×2 جوال، 4 أعمدة سطح مكتب
// تعتمد على ClinicStatisticsEntity من طبقة الـ Domain
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/clinic_statistics_entity.dart';

class ClinicSummaryCards extends StatelessWidget {
  final ClinicStatisticsEntity statistics;

  const ClinicSummaryCards({super.key, required this.statistics});

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
            // مواعيد اليوم
            _SummaryCard(
              icon: Icons.event,
              iconBg: context.warningBg,
              iconColor: context.warningText,
              value: _formatNumber(statistics.dayAppointments),
              label: AppStrings.todayAppointments,
              change: AppStrings.remainingAppointments(
                  statistics.dayAppointments -
                      statistics.numberOfFinishedAppointments),
              changeColor: context.textSecondary,
            ),
            // عدد الأطباء
            _SummaryCard(
              icon: Icons.medical_services_outlined,
              iconBg: context.primaryLightColor,
              iconColor: context.primary,
              value: '${statistics.numberOfDoctors}',
              label: AppStrings.doctors,
              change: statistics.numberOfDoctors > 0
                  ? AppStrings.active
                  : AppStrings.none,
              changeColor: context.textSecondary,
            ),
            // إيرادات الشهر
            _SummaryCard(
              icon: Icons.payments_outlined,
              iconBg: context.successBg,
              iconColor: context.successText,
              value:
                  '${_formatNumber(statistics.monthlyRevenue.toInt())} ${AppStrings.egp}',
              label: AppStrings.monthlyRevenue,
              change: AppStrings.active,
              changeColor: context.successText,
            ),
            // المواعيد المكتملة
            _SummaryCard(
              icon: Icons.check_circle_outline,
              iconBg: context.primaryLightColor,
              iconColor: context.primary,
              value: '${statistics.numberOfFinishedAppointments}',
              label: AppStrings.completedAppointments,
              change: AppStrings.today,
              changeColor: context.textSecondary,
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
      padding:
          const EdgeInsets.all(AppConstants.spaceSm + AppConstants.spaceXs),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.border),
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
                    color: context.textSecondary,
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
                child:
                    Icon(icon, size: AppConstants.iconSizeMd, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context).copyWith(
              color: context.textPrimary,
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
