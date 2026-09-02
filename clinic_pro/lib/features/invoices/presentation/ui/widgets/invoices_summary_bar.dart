// ────────────────────────────────────────────────────────
// InvoicesSummaryBar — شريط كروت الإحصائيات المالية العليا
// يعرض المبالغ المحصلة، الفواتير المتبقية، والزيارات غير المفوترة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/invoices_state.dart';

class InvoicesSummaryBar extends StatelessWidget {
  final InvoicesState state;

  const InvoicesSummaryBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 380;

    return ResponsiveHelper.responsiveCenter(
      maxWidth: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.payments_outlined,
                label: AppStrings.isArabic ? 'المحصل' : 'Collected',
                subtitle: AppStrings.isArabic ? 'المسدد فعلياً' : 'Paid cash',
                value: state.totalRevenue.toStringAsFixed(0),
                currency: AppStrings.egp,
                color: context.accent,
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                icon: Icons.pending_actions_outlined,
                label: AppStrings.isArabic ? 'دفعات متبقية' : 'Invoices Remaining',
                subtitle: AppStrings.isArabic ? 'متبقي الفواتير' : 'Unpaid invoices',
                value: state.totalPending.toStringAsFixed(0),
                currency: AppStrings.egp,
                color: context.danger,
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                icon: Icons.hourglass_empty_outlined,
                label: AppStrings.isArabic ? 'غير مفوتر' : 'Unbilled Visits',
                subtitle: AppStrings.isArabic
                    ? '${state.filteredUnbilledAppointments.length} زيارة بدون فاتورة'
                    : '${state.filteredUnbilledAppointments.length} unbilled visits',
                value: state.unbilledTotalAmount.toStringAsFixed(0),
                currency: AppStrings.egp,
                color: context.warning,
                isSmallScreen: isSmallScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final String currency;
  final Color color;
  final bool isSmallScreen;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.currency,
    required this.color,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isSmallScreen ? 14 : 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    value,
                    key: ValueKey(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: isSmallScreen ? 15 : 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                currency,
                style: AppTextStyles.caption(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 9 : 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: isSmallScreen ? 8 : 10,
            ),
          ),
        ],
      ),
    );
  }
}