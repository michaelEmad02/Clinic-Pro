// ────────────────────────────────────────────────────────
// بطاقة الفاتورة المرتبطة بالموعد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border),
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
                  'الفاتورة',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (hasInvoice && isPaid)
                const StatusBadge(text: 'مدفوع', status: BadgeStatus.success),
            ],
          ),
          const SizedBox(height: 12),
          if (hasInvoice) ...[
            if (amount != null)
              Text(
                '$amount ر.س',
                style: AppTextStyles.dataNumeric(context).copyWith(fontSize: 18),
              ),
            if (invoiceNumber != null) ...[
              const SizedBox(height: 6),
              Text(
                'رقم الفاتورة $invoiceNumber',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('سيتم فتح الفاتورة في المرحلة المالية')),
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
              child: const Text('عرض الفاتورة'),
            ),
          ] else ...[
            Text(
              'لم تُسجَّل فاتورة بعد',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('سيتم تفعيل تسجيل الفاتورة في المرحلة المالية')),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('تسجيل فاتورة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                backgroundColor: AppColors.primaryLight,
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
