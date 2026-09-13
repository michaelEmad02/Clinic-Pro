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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isWide = availableWidth >= 1100;

        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'مواعيد اليوم' : 'Today Appointments',
                    value: '$todayAppointmentsCount',
                    icon: Icons.calendar_today_outlined,
                    color: context.primary,
                    bgColor: context.primaryLightColor,
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
                    value: '$completedCount',
                    icon: Icons.check_circle_outline,
                    color: context.successText,
                    bgColor: context.successBg,
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
                    value: '$waitingCount',
                    icon: Icons.hourglass_empty_outlined,
                    color: context.warningText,
                    bgColor: context.warningBg,
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
                    value: avgWaitingTime,
                    icon: Icons.access_time,
                    color: context.primaryContainer,
                    bgColor: context.primaryLightColor,
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'إيرادات اليوم' : "Today's Revenue",
                    value: '${todayRevenue.toStringAsFixed(0)} ${AppStrings.sar}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: context.primary,
                    bgColor: context.primaryLightColor,
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    title: AppStrings.isArabic ? 'المحصل' : 'Collected Amount',
                    value: '${collectedAmount.toStringAsFixed(0)} ${AppStrings.sar}',
                    icon: Icons.price_check_outlined,
                    color: context.successText,
                    bgColor: context.successBg,
                    isWide: true,
                  ),
                ),
              ],
            ),
          );
        }

        // For smaller window widths (< 1100px), use smooth horizontal scrollable GridView
        return SizedBox(
          height: isMobile ? 200 : 104,
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: isMobile ? 2 : 1,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isMobile ? 0.44 : 0.38,
            children: [
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'مواعيد اليوم' : 'Today Appointments',
                value: '$todayAppointmentsCount',
                icon: Icons.calendar_today_outlined,
                color: context.primary,
                bgColor: context.primaryLightColor,
                isWide: false,
              ),
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
                color: context.successText,
                bgColor: context.successBg,
                isWide: false,
              ),
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
                value: '$waitingCount',
                icon: Icons.hourglass_empty_outlined,
                color: context.warningText,
                bgColor: context.warningBg,
                isWide: false,
              ),
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
                value: avgWaitingTime,
                icon: Icons.access_time,
                color: context.primaryContainer,
                bgColor: context.primaryLightColor,
                isWide: false,
              ),
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'إيرادات اليوم' : "Today's Revenue",
                value: '${todayRevenue.toStringAsFixed(0)} ${AppStrings.sar}',
                icon: Icons.account_balance_wallet_outlined,
                color: context.primary,
                bgColor: context.primaryLightColor,
                isWide: false,
              ),
              _buildStatItem(
                context: context,
                title: AppStrings.isArabic ? 'المحصل' : 'Collected Amount',
                value: '${collectedAmount.toStringAsFixed(0)} ${AppStrings.sar}',
                icon: Icons.price_check_outlined,
                color: context.successText,
                bgColor: context.successBg,
                isWide: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isWide,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 14 : 12,
        vertical: isWide ? 16 : 10,
      ),
      constraints: BoxConstraints(minHeight: isWide ? 88 : 0),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(isWide ? 16 : 14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isWide ? 10 : 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(isWide ? 12 : 8),
            ),
            child: Icon(icon, color: color, size: isWide ? 24 : 20),
          ),
          SizedBox(width: isWide ? 12 : 10),
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
                    fontWeight: FontWeight.w600,
                    fontSize: isWide ? 13 : 12,
                  ),
                ),
                SizedBox(height: isWide ? 5 : 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      fontSize: isWide ? 20 : 15,
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
