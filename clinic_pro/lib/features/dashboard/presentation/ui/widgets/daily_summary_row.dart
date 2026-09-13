// ─────────────────────────────────────────
// هذا الملف يحتوي على صف إحصائيات الأداء اليومي لمكتب الاستقبال
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';

class DailySummaryRow extends StatelessWidget {
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;

  const DailySummaryRow({
    super.key,
    required this.todayAppointmentsCount,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: AppStrings.isArabic ? 'مواعيد اليوم' : 'Today Appointments',
              value: '$todayAppointmentsCount',
              icon: Icons.calendar_today_outlined,
              color: context.primary,
              bgColor: context.primaryLightColor,
              isDesktop: true,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
              value: '$completedCount',
              icon: Icons.check_circle_outline,
              color: context.successText,
              bgColor: context.successBg,
              isDesktop: true,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
              value: '$waitingCount',
              icon: Icons.hourglass_empty_outlined,
              color: context.warningText,
              bgColor: context.warningBg,
              isDesktop: true,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
              value: avgWaitingTime,
              icon: Icons.access_time,
              color: context.primaryContainer,
              bgColor: context.primaryLightColor,
              isDesktop: true,
            ),
          ),
        ],
      );
    }

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
          _buildSummaryItem(
            context: context,
            title: AppStrings.isArabic ? 'مواعيد اليوم' : 'Today Appointments',
            value: '$todayAppointmentsCount',
            icon: Icons.calendar_today_outlined,
            color: context.primary,
            bgColor: context.primaryLightColor,
          ),
          _buildSummaryItem(
            context: context,
            title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
            value: '$completedCount',
            icon: Icons.check_circle_outline,
            color: context.successText,
            bgColor: context.successBg,
          ),
          _buildSummaryItem(
            context: context,
            title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
            value: '$waitingCount',
            icon: Icons.hourglass_empty_outlined,
            color: context.warningText,
            bgColor: context.warningBg,
          ),
          _buildSummaryItem(
            context: context,
            title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
            value: avgWaitingTime,
            icon: Icons.access_time,
            color: context.primaryContainer,
            bgColor: context.primaryLightColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 14 : 10,
        vertical: isDesktop ? 14 : 8,
      ),
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
            padding: EdgeInsets.all(isDesktop ? 10 : 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
            ),
            child: Icon(icon, color: color, size: isDesktop ? 22 : 18),
          ),
          SizedBox(width: isDesktop ? 12 : 8),
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
                    fontSize: isDesktop ? 12.5 : 11,
                  ),
                ),
                SizedBox(height: isDesktop ? 4 : 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      fontSize: isDesktop ? 20 : 15,
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
