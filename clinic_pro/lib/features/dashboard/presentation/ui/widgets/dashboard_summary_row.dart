// ─────────────────────────────────────────
// كروت إحصائيات لوحة التحكم بخطوط شبكية متجاوبة (Responsive GridView)
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';

class DashboardSummaryRow extends StatelessWidget {
  final num todayNetRevenue;
  final int totalPatients;
  final int todayAppointments;
  final int todayCompletedAppointments;

  const DashboardSummaryRow({
    super.key,
    required this.todayNetRevenue,
    required this.totalPatients,
    required this.todayAppointments,
    required this.todayCompletedAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    // ── Desktop Layout (Full width row with rich KPI cards) ──
    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            Expanded(
              child: _buildBentoCard(
                context: context,
                title: AppStrings.isArabic ? 'صافي إيراد اليوم' : 'Today Net Revenue',
                value: '${todayNetRevenue.toStringAsFixed(0)} ${AppStrings.sar}',
                icon: Icons.payments_outlined,
                iconBgColor: context.successBg,
                iconColor: context.successText,
                hasRightAccent: true,
                accentColor: context.accent,
                isDesktop: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoCard(
                context: context,
                title: AppStrings.todayAppointments,
                value: '$todayCompletedAppointments / $todayAppointments',
                icon: Icons.today_outlined,
                iconBgColor: context.warningBg,
                iconColor: context.warningText,
                hasRightAccent: true,
                accentColor: context.warning,
                isDesktop: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoCard(
                context: context,
                title: AppStrings.totalPatients,
                value: '$totalPatients',
                icon: Icons.people_outline,
                iconBgColor: context.primaryLightColor,
                iconColor: context.primaryContainer,
                hasRightAccent: true,
                accentColor: context.primaryContainer,
                isDesktop: true,
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile & Tablet Layout (Preserved Exactly) ──
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: isMobile ? 2 : 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isMobile ? 1.55 : 1.85,
        children: [
          _buildBentoCard(
            context: context,
            title: AppStrings.isArabic ? 'صافي إيراد اليوم' : 'Today Net Revenue',
            value: todayNetRevenue.toStringAsFixed(0),
            icon: Icons.payments_outlined,
            iconBgColor: context.successBg,
            iconColor: context.successText,
            hasRightAccent: true,
            accentColor: context.accent,
            isDesktop: false,
          ),
          _buildBentoCard(
            context: context,
            title: AppStrings.todayAppointments,
            value: '$todayCompletedAppointments / $todayAppointments',
            icon: Icons.today_outlined,
            iconBgColor: context.warningBg,
            iconColor: context.warningText,
            accentColor: context.warning,
            isDesktop: false,
          ),
          _buildBentoCard(
            context: context,
            title: AppStrings.totalPatients,
            value: '$totalPatients',
            icon: Icons.people_outline,
            iconBgColor: context.primaryLightColor,
            iconColor: context.primaryContainer,
            accentColor: context.primaryContainer,
            isDesktop: false,
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
    required bool isDesktop,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 92 : 0),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
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
            // Right Accent Border
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
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 18 : 12,
                vertical: isDesktop ? 16 : 12,
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.dataNumeric(context).copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
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
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.dataNumeric(context).copyWith(
                                  fontSize: 18,
                                  color: context.textPrimary,
                                ),
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
