import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class DoctorStatsRow extends StatelessWidget {
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;

  const DoctorStatsRow({
    super.key,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context: context,
              title: AppStrings.isArabic ? 'مكتمل اليوم' : 'Completed Today',
              value: '$completedCount',
              icon: Icons.check_circle_outline,
              color: AppColors.successText,
              bgColor: AppColors.successBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              context: context,
              title: AppStrings.isArabic ? 'قيد الانتظار' : 'Waiting',
              value: '$waitingCount',
              icon: Icons.hourglass_empty_outlined,
              color: AppColors.warningText,
              bgColor: AppColors.warningBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              context: context,
              title: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait Time',
              value: avgWaitingTime,
              icon: Icons.access_time,
              color: AppColors.primaryContainer,
              bgColor: context.primaryLightColor,
            ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.dataNumeric(context).copyWith(
              fontSize: 15,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
