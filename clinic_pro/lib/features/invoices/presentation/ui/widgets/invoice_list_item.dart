import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/invoices_state.dart';
import 'invoice_action_sheet.dart';

class InvoiceListItem extends StatelessWidget {
  final InvoiceItem invoice;

  const InvoiceListItem({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.patientName,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${invoice.formattedDate} • ${invoice.appointmentType}',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.totalAmount.toStringAsFixed(0),
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  invoice.paidAmount.toStringAsFixed(0),
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    fontWeight: FontWeight.normal,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  InvoiceActionSheet.show(
                    context: context,
                    invoice: invoice,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}