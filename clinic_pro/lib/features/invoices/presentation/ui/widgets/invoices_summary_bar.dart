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
    final paddingValue = isSmallScreen ? 8.0 : 12.0;

    return ResponsiveHelper.responsiveCenter(
      maxWidth: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
             Expanded(
              child: _SummaryCard(
                label: AppStrings.isArabic ? 'عدد الفواتير' : 'Invoices Count',
                value: state.filteredInvoices.length.toString(),
                currency: AppStrings.invoice,
                color: context.primaryFixedDim,
                padding: paddingValue,
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: AppStrings.isArabic ? 'إجمالي المحصل' : 'Total Collected',
                value: state.totalRevenue.toStringAsFixed(0),
                currency: AppStrings.egp,
                color: context.accent,
                padding: paddingValue,
                isSmallScreen: isSmallScreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                label: AppStrings.isArabic ? 'إجمالي المتبقي' : 'Total Remaining',
                value: state.totalPending.toStringAsFixed(0),
                currency: AppStrings.egp,
                color: context.danger,
                padding: paddingValue,
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
  final String label;
  final String value;
  final String currency;
  final Color color;
  final double padding;
  final bool isSmallScreen;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.currency,
    required this.color,
    required this.padding,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
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
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: isSmallScreen ? 10 : 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isSmallScreen ? 16 : 20,
                  ),
                ),
              ),
              // const SizedBox(width: 2),
              // Text(
              //   currency,
              //   style: AppTextStyles.caption(context).copyWith(
              //     color: color,
              //     fontSize: isSmallScreen ? 9 : 11,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}