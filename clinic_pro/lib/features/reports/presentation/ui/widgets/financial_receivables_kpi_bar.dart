// ────────────────────────────────────────────────────────
// FinancialReceivablesKpiBar — شريط كروت الإحصائيات لمتقرير المستحقات مع تحليل أعمار الديون
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/reports/domain/entities/financial_receivables_entity.dart';
import 'package:flutter/material.dart';

class FinancialReceivablesKpiBar extends StatelessWidget {
  final FinancialReceivablesEntity report;

  const FinancialReceivablesKpiBar({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final cards = [
      _ReceivableKpiCard(
        title: AppStrings.isArabic ? 'إجمالي المستحقات' : 'Total Receivables',
        amount: report.totalReceivables,
        subtitle: AppStrings.isArabic ? 'شامل الفواتير والزيارات المعلقة' : 'Invoices & Visits',
        icon: Icons.account_balance_wallet_outlined,
        color: context.primary,
        isCurrency: true,
      ),
      _ReceivableKpiCard(
        title: AppStrings.isArabic ? 'ديون الفواتير الصادرة' : 'Pending Invoices',
        amount: report.issuedInvoicesPending,
        subtitle: AppStrings.isArabic ? 'فواتير غير محصلة بالكامل' : 'Issued unpaid invoices',
        icon: Icons.receipt_long_outlined,
        color: context.warning,
        isCurrency: true,
      ),
      _ReceivableKpiCard(
        title: AppStrings.isArabic ? 'زيارات بانتظار التفوتر' : 'Unbilled Visits Amount',
        amount: report.unbilledVisitsAmount,
        subtitle: AppStrings.isArabic ? 'زيارات مكتملة تنتظر الفاتورة' : 'Completed visits unbilled',
        icon: Icons.hourglass_empty_rounded,
        color: context.danger,
        isCurrency: true,
      ),
      _ReceivableKpiCard(
        title: AppStrings.isArabic ? 'المرضى المديونين' : 'Debtor Patients',
        amount: report.debtorPatientsCount.toDouble(),
        subtitle: AppStrings.isArabic ? 'عدد المرضى المطلوبين' : 'Patients owing money',
        icon: Icons.people_alt_outlined,
        color: context.accent,
        isCurrency: false,
      ),
    ];

    return Column(
      children: [
        if (isMobile)
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => SizedBox(
                width: 220,
                child: cards[index],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: cards,
            ),
          ),
        const SizedBox(height: 12),
        // مؤشر أعمار الديون (Aging Analysis Bar)
        _AgingAnalysisBar(aging: report.aging),
      ],
    );
  }
}

class _ReceivableKpiCard extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const _ReceivableKpiCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isCurrency
                  ? '${amount.toStringAsFixed(0)} ${AppStrings.egp}'
                  : amount.toInt().toString(),
              key: ValueKey(amount),
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: context.textSecondary.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AgingAnalysisBar extends StatelessWidget {
  final ReceivableAgingEntity aging;

  const _AgingAnalysisBar({required this.aging});

  @override
  Widget build(BuildContext context) {
    final total = aging.under7Days + aging.days7To30 + aging.over30Days;
    if (total <= 0) return const SizedBox.shrink();

    final pctUnder7 = (aging.under7Days / total) * 100;
    final pct7To30 = (aging.days7To30 / total) * 100;
    final pctOver30 = (aging.over30Days / total) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, size: 14, color: context.primary),
                const SizedBox(width: 4),
                Text(
                  AppStrings.isArabic ? 'تحليل أعمار الديون:' : 'Debt Aging Analysis:',
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    if (pctUnder7 > 0)
                      Expanded(
                        flex: (pctUnder7 * 10).toInt(),
                        child: Container(color: context.accent),
                      ),
                    if (pct7To30 > 0)
                      Expanded(
                        flex: (pct7To30 * 10).toInt(),
                        child: Container(color: context.warning),
                      ),
                    if (pctOver30 > 0)
                      Expanded(
                        flex: (pctOver30 * 10).toInt(),
                        child: Container(color: context.danger),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              children: [
                _AgingBadge(
                  label: AppStrings.isArabic ? 'حديثة (< 7 أيام)' : '< 7 Days',
                  amount: aging.under7Days,
                  color: context.accent,
                ),
                _AgingBadge(
                  label: AppStrings.isArabic ? 'متوسطة (7 - 30 يوماً)' : '7-30 Days',
                  amount: aging.days7To30,
                  color: context.warning,
                ),
                _AgingBadge(
                  label: AppStrings.isArabic ? 'متأخرة (> 30 يوماً)' : '> 30 Days',
                  amount: aging.over30Days,
                  color: context.danger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgingBadge extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AgingBadge({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${amount.toStringAsFixed(0)} ${AppStrings.egp}',
          style: TextStyle(
            fontSize: 10,
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
