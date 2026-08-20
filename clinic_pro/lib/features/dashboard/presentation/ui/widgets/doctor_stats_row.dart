// ─────────────────────────────────────────
// كروت إحصائيات لوحة تحكم الطبيب المتجاوبة (Responsive Doctor Stats Row)
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class DoctorStatsRow extends StatelessWidget {
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;
  final double todayRevenue;
  final double collectedAmount;

  const DoctorStatsRow({
    super.key,
    required this.todayAppointmentsCount,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
    required this.todayRevenue,
    required this.collectedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return SizedBox(
      height: isMobile ? 190 : 95,
      child: GridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: isMobile ? 2 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isMobile ? 0.46 : 0.42,
        children: [
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'مواعيد اليوم' : 'Today Appointments',
            value: '$todayAppointmentsCount',
            icon: Icons.calendar_today_outlined,
            color: context.primary,
            bgColor: context.primaryLightColor,
          ),
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
            value: '$completedCount',
            icon: Icons.check_circle_outline,
            color: context.successText,
            bgColor: context.successBg,
          ),
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
            value: '$waitingCount',
            icon: Icons.hourglass_empty_outlined,
            color: context.warningText,
            bgColor: context.warningBg,
          ),
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
            value: avgWaitingTime,
            icon: Icons.access_time,
            color: context.primaryContainer,
            bgColor: context.primaryLightColor,
          ),
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'إيرادات اليوم' : "Today's Revenue",
            value: '${todayRevenue.toStringAsFixed(0)} ${AppStrings.sar}',
            icon: Icons.account_balance_wallet_outlined,
            color: context.primary,
            bgColor: context.primaryLightColor,
          ),
          _buildStatItem(
            context: context,
            title: AppStrings.isArabic ? 'المحصل' : 'Collected Amount',
            value: '${collectedAmount.toStringAsFixed(0)} ${AppStrings.sar}',
            icon: Icons.price_check_outlined,
            color: context.successText,
            bgColor: context.successBg,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
