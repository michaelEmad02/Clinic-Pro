import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class DashboardSummaryRow extends StatelessWidget {
  final num totalRevenue;
  final int totalPatients;
  final int todayAppointments;
  final int activeClinics;

  const DashboardSummaryRow({
    super.key,
    required this.totalRevenue,
    required this.totalPatients,
    required this.todayAppointments,
    required this.activeClinics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildBentoCard(
            context: context,
            title: AppStrings.totalRevenue,
            value: '\$${totalRevenue.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            iconBgColor: AppColors.successBg,
            iconColor: AppColors.successText,
            hasRightAccent: true,
            accentColor: AppColors.accent,
          ),
          const SizedBox(width: 12),
          _buildBentoCard(
            context: context,
            title: AppStrings.totalPatients,
            value: '$totalPatients',
            icon: Icons.people_outline,
            iconBgColor: context.primaryLightColor,
            iconColor: AppColors.primaryContainer,
            accentColor: AppColors.primaryContainer,
          ),
          const SizedBox(width: 12),
          _buildBentoCard(
            context: context,
            title: AppStrings.todayAppointments,
            value: '$todayAppointments',
            icon: Icons.today_outlined,
            iconBgColor: AppColors.warningBg,
            iconColor: AppColors.warningText,
            accentColor: AppColors.warning,
          ),
          const SizedBox(width: 12),
          _buildBentoCard(
            context: context,
            title: AppStrings.activeClinics,
            value: '$activeClinics',
            icon: Icons.business_outlined,
            iconBgColor: AppColors.iconBg, // purple tint
            iconColor: AppColors.icon, // purple
            accentColor: AppColors.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool hasRightAccent = true,
    Color? accentColor,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative Circle Overlay
            Positioned(
              top: -24,
              left: -24,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Left Accent Border
            if (hasRightAccent && accentColor != null)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  width: 4,
                  color: accentColor,
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          fontSize: 18,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
