import 'package:flutter/material.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/clinic_report_entity.dart';

class ClinicSummaryCards extends StatelessWidget {
  final ClinicReportEntity report;

  const ClinicSummaryCards({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CardItem(
                  label: AppStrings.isArabic ? 'العيادات النشطة' : 'Active Clinics',
                  value: report.totalActiveClinics.toString(),
                  icon: Icons.local_hospital_rounded,
                  iconColor: context.primary,
                  bgColor: context.primaryLightColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CardItem(
                  label: AppStrings.isArabic ? 'إجمالي الأطباء' : 'Total Doctors',
                  value: report.totalDoctors.toString(),
                  icon: Icons.badge_rounded,
                  iconColor: Colors.purple,
                  bgColor: Colors.purple.withOpacity(0.12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CardItem(
                  label: AppStrings.isArabic ? 'الإيراد المتوقع' : 'Expected Revenue',
                  value: '${report.totalExpectedRevenue.toStringAsFixed(0)} ${AppStrings.egp}',
                  icon: Icons.event_note_rounded,
                  iconColor: Colors.orange,
                  bgColor: Colors.orange.withOpacity(0.12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CardItem(
                  label: AppStrings.isArabic ? 'المحصل الفعلي' : 'Collected Revenue',
                  value: '${report.totalCollectedAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                  icon: Icons.payments_rounded,
                  iconColor: context.successText,
                  bgColor: context.successBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CardItem(
                  label: AppStrings.expenses,
                  value: '${report.totalExpenses.toStringAsFixed(0)} ${AppStrings.egp}',
                  icon: Icons.trending_down_rounded,
                  iconColor: context.dangerText,
                  bgColor: context.dangerBg,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CardItem(
                  label: AppStrings.isArabic ? 'صافي الأرباح' : 'Net Profit',
                  value: '${report.totalNetProfit.toStringAsFixed(0)} ${AppStrings.egp}',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: Colors.indigo,
                  bgColor: Colors.indigo.withOpacity(0.12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _CardItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
