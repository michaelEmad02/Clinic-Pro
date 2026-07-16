import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class BillingHistoryList extends StatelessWidget {
  const BillingHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.billingHistory, style: AppTextStyles.headlineSmall(context)),
            TextButton(
              onPressed: () {},
              child: Text(AppStrings.viewAll, style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              _buildInvoiceItem(
                context,
                date: '24 سبتمبر، 2023',
                amount: '0 ريال',
                invoice: '#INV-2309',
                status: AppStrings.trial,
              ),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border, indent: AppConstants.spaceMd, endIndent: AppConstants.spaceMd),
              _buildEmptyState(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceItem(
    BuildContext context, {
    required String date,
    required String amount,
    required String invoice,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice, style: AppTextStyles.bodyMedium(context)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(date, style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: AppConstants.spaceSm),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.border)),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(amount, style: AppTextStyles.dataNumeric(context)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            ),
            child: Text(status, style: AppTextStyles.labelChip(context).copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppConstants.radiusCard - 1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.border),
          const SizedBox(height: AppConstants.spaceSm),
          Text(AppStrings.noBillingHistory,
              style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
