// ────────────────────────────────────────────────────────
// بطاقة الفاتورة المرتبطة بالموعد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/status_badge.dart';

class LinkedInvoiceCard extends StatelessWidget {
  final bool hasInvoice;
  final String? amount;
  final String? status;
  final String? invoiceNumber;

  const LinkedInvoiceCard({
    super.key,
    required this.hasInvoice,
    this.amount,
    this.status,
    this.invoiceNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'paid';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.invoice,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (hasInvoice && isPaid)
                StatusBadge(text: AppStrings.paid, status: BadgeStatus.success),
            ],
          ),
          const SizedBox(height: 12),
          if (hasInvoice) ...[
            if (amount != null)
              Text(
                '$amount ${AppStrings.sar}',
                style: AppTextStyles.dataNumeric(context).copyWith(fontSize: 18),
              ),
            if (invoiceNumber != null) ...[
              const SizedBox(height: 6),
              Text(
                '${AppStrings.invoiceNumber} $invoiceNumber',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppStrings.isArabic ? 'سيتم فتح الفاتورة في المرحلة المالية' : 'Invoice will be opened in the financial module')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
              child: Text(AppStrings.viewInvoice),
            ),
          ] else ...[
            Text(
              AppStrings.noInvoiceYet,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppStrings.isArabic ? 'سيتم تفعيل تسجيل الفاتورة في المرحلة المالية' : 'Invoice registration will be available in the financial module')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.createInvoice),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                backgroundColor: context.primaryLightColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
