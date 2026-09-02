// ────────────────────────────────────────────────────────
// InvoiceListItem — مكون كارت الفاتورة الفردي في القائمة
// يعرض تفاصيل الفاتورة، الحالة، اسم المريض، ومنشئ الفاتورة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import 'invoice_action_sheet.dart';

class InvoiceListItem extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoiceListItem({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final dateStr = invoice.createdAt.toIso8601String().length >= 10
        ? invoice.createdAt.toIso8601String().substring(0, 10)
        : invoice.createdAt.toIso8601String();

    Color statusColor = context.primary;
    if (invoice.status == InvoiceStatus.pending) {
      statusColor = context.danger;
    } else if (invoice.status == InvoiceStatus.partial) {
      statusColor = context.warning;
    } else {
      statusColor = context.accent;
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    final margin = isMobile
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
        : EdgeInsets.zero;

    return Container(
      margin: margin,
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
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.patientName ?? AppStrings.unknownPatient,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateStr • ${invoice.appointmentTypeName ?? (AppStrings.isArabic ? "كشف عام" : "General Checkup")}',
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (invoice.createdByName != null &&
                      invoice.createdByName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 12, color: context.primary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${AppStrings.isArabic ? "بواسطة" : "By"}: ${invoice.createdByName}',
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${invoice.paidAmount.toStringAsFixed(0)} / ${invoice.totalAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getLocalStatusText(invoice.status),
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
                icon: Icon(Icons.more_vert,
                    size: 18, color: context.textSecondary),
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

  String _getLocalStatusText(InvoiceStatus status) {
    if (AppStrings.isArabic) {
      switch (status) {
        case InvoiceStatus.pending:
          return 'معلق';
        case InvoiceStatus.partial:
          return 'جزئي';
        case InvoiceStatus.paid:
          return 'مدفوع';
      }
    } else {
      switch (status) {
        case InvoiceStatus.pending:
          return 'Pending';
        case InvoiceStatus.partial:
          return 'Partial';
        case InvoiceStatus.paid:
          return 'Paid';
      }
    }
  }
}