import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class DrugKpiCardsWidget extends StatelessWidget {
  final DrugStatsEntity stats;

  const DrugKpiCardsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // ضبط childAspectRatio بحسب عدد الأعمدة
    final double aspectRatio = isDesktop
        ? 2.2
        : (isTablet
            ? 1.8
            : 1.5);

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
      crossAxisSpacing: AppConstants.spaceSm,
      mainAxisSpacing: AppConstants.spaceSm,
      childAspectRatio: aspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKpiCard(
          context,
          title: 'إجمالي الروشتات',
          value: '${stats.totalPrescriptions}',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF1A6B8A),
        ),
        _buildKpiCard(
          context,
          title: 'متوسط أدوية / روشتة',
          value: stats.avgDrugsPerPrescription.toStringAsFixed(1),
          icon: Icons.medication_liquid_rounded,
          color: const Color(0xFF2ECC9A),
        ),
        _buildKpiCard(
          context,
          title: 'نسبة أدوية PRN',
          value: '${stats.prnPercentage.toStringAsFixed(1)}%',
          icon: Icons.access_time_filled_rounded,
          color: const Color(0xFFF5A623),
        ),
        _buildKpiCard(
          context,
          title: 'أكثر تشخيص شيوعاً',
          value: stats.topDiagnosisName.isNotEmpty ? stats.topDiagnosisName : 'لا يوجد',
          icon: Icons.local_hospital_rounded,
          color: const Color(0xFF9B59B6),
          isSmallText: true,
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isSmallText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor, width: 0.5),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isSmallText
                ? AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  )
                : AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}
