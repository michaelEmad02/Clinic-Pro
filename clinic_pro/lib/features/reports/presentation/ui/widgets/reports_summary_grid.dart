// ────────────────────────────────────────────────────────
// شبكة الملخص (Bento Grid) — الإيرادات، المصروفات، الصافي، المرضى
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../manager/reports_state.dart';

class ReportsSummaryGrid extends StatelessWidget {
  final ReportSummary summary;

  const ReportsSummaryGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveHelper.isMobile(context);

    final cardExpected = _SummaryCard(
      label: AppStrings.isArabic ? 'الإيراد المتوقع' : 'Expected Rev.',
      value: summary.revenue.toStringAsFixed(0),
      currency: AppStrings.egp,
      change: summary.revenueChange,
      changeColor: context.primary,
      icon: Icons.event_note_rounded,
      iconBg: context.primaryLightColor,
      iconColor: context.primary,
    );

    final cardCollected = _SummaryCard(
      label: AppStrings.isArabic ? 'المُحصل الفعلي' : 'Collected',
      value: summary.collected.toStringAsFixed(0),
      currency: AppStrings.egp,
      change: summary.revenueChange,
      changeColor: context.successText,
      icon: Icons.payments_rounded,
      iconBg: context.successBg,
      iconColor: context.successText,
    );

    final cardExpenses = _SummaryCard(
      label: AppStrings.expenses,
      value: summary.expenses.toStringAsFixed(0),
      currency: AppStrings.egp,
      change: summary.expensesChange,
      changeColor: context.dangerText,
      icon: Icons.trending_down,
      iconBg: context.dangerBg,
      iconColor: context.dangerText,
    );

    final cardNetProfit = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x291A6B8A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.isArabic ? 'الصافي (المحصل - المصروفات)' : 'Net Profit',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.onPrimaryContainer,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    summary.netProfit.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.egp,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isWide
          ? Row(
              children: [
                Expanded(child: cardExpected),
                const SizedBox(width: 8),
                Expanded(child: cardCollected),
                const SizedBox(width: 8),
                Expanded(child: cardExpenses),
                const SizedBox(width: 8),
                Expanded(child: cardNetProfit),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: cardExpected),
                    const SizedBox(width: 8),
                    Expanded(child: cardCollected),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: cardExpenses),
                    const SizedBox(width: 8),
                    Expanded(child: cardNetProfit),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String currency;
  final String change;
  final Color changeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.currency,
    required this.change,
    required this.changeColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
