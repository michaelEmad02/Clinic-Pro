import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class DailySummaryRow extends StatelessWidget {
  final String totalInvoiced;
  final String totalCollected;
  final int totalAppointmentsCount;

  const DailySummaryRow({
    super.key,
    required this.totalInvoiced,
    required this.totalCollected,
    required this.totalAppointmentsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: 'الفواتير اليوم',
              value: '\$$totalInvoiced',
              icon: Icons.receipt_long_outlined,
              color: AppColors.primary,
              bgColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: 'المحصل اليوم',
              value: '\$$totalCollected',
              icon: Icons.payments_outlined,
              color: AppColors.successText,
              bgColor: AppColors.successBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryItem(
              context: context,
              title: 'إجمالي المواعيد',
              value: '$totalAppointmentsCount',
              icon: Icons.calendar_today_outlined,
              color: AppColors.warningText,
              bgColor: AppColors.warningBg,
            ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.dataNumeric(context).copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
