// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الفاتورة (···) + تسديد دفعة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_invoice_sheet.dart';

class InvoiceActionSheet {
  static Future<void> show({
    required BuildContext context,
    required InvoiceEntity invoice,
  }) {
    final clinicId = context.read<SettingsCubit>().state.clinicEntity?.id ?? '';
    final dateStr = invoice.createdAt.toIso8601String().length >= 10
        ? invoice.createdAt.toIso8601String().substring(0, 10)
        : invoice.createdAt.toIso8601String();

    final invoicesCubit = context.read<InvoicesCubit>();
    final allInvoices = invoicesCubit.state.invoices;

    double visitPrice = invoice.totalAmount;
    double totalPaidForVisit = invoice.paidAmount;

    if (invoice.sourceType == 'appointment' && invoice.sourceId.isNotEmpty) {
      final relatedInvoices = allInvoices.where((inv) => inv.sourceId == invoice.sourceId);
      if (relatedInvoices.isNotEmpty) {
        visitPrice = relatedInvoices.first.totalAmount;
        totalPaidForVisit = relatedInvoices.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);
      }
    }

    final actualRemaining = (visitPrice - totalPaidForVisit) > 0 ? (visitPrice - totalPaidForVisit) : 0.0;

    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.patientName ?? AppStrings.unknownPatient,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              invoice.appointmentTypeName ?? (AppStrings.isArabic ? 'كشف عام' : 'General Checkup'),
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: AppStrings.total,
              value:
                  '${invoice.totalAmount.toStringAsFixed(0)} ${AppStrings.egp}',
            ),
            _DetailRow(
              label: AppStrings.paid,
              value:
                  '${invoice.paidAmount.toStringAsFixed(0)} ${AppStrings.egp}',
              valueColor: invoice.paidAmount >= invoice.totalAmount
                  ? context.accent
                  : context.danger,
            ),
            _DetailRow(
              label: AppStrings.paymentMethod,
              value: _getLocalPaymentMethod(invoice.paymentMethod),
            ),
            _DetailRow(
              label: AppStrings.date,
              value: dateStr,
            ),
            const SizedBox(height: 20),
            if (actualRemaining > 0) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPaymentDialog(context, invoice, actualRemaining);
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(AppStrings.isArabic ? 'تسديد دفعة إضافية' : 'Pay Additional Amount'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  AddInvoiceSheet.show(context, invoice: invoice);
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(AppStrings.isArabic ? 'تعديل الفاتورة' : 'Edit Invoice'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primary,
                  side: BorderSide(color: context.primary),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(AppStrings.isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
                      content: Text(AppStrings.isArabic
                          ? 'هل أنت متأكد من حذف هذه الفاتورة؟ يؤثر هذا الإجراء على التقارير المالية.'
                          : 'Are you sure you want to delete this invoice? This action affects financial reports.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(AppStrings.delete,
                              style: TextStyle(color: context.danger)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    Navigator.pop(context);
                    context
                        .read<InvoicesCubit>()
                        .deleteInvoice(invoice.id, clinicId);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(AppStrings.delete),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.danger,
                  side: BorderSide(color: context.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPaymentDialog(BuildContext context, InvoiceEntity invoice, double remaining) {
    final controller =
        TextEditingController(text: remaining.toStringAsFixed(0));
    final cubit = context.read<InvoicesCubit>();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppStrings.isArabic ? 'تسديد دفعة نقدية' : 'Pay Cash Amount'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${AppStrings.isArabic ? "المبلغ المتبقي" : "Remaining Amount"}: ${remaining.toStringAsFixed(0)} ${AppStrings.egp}'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (errorMessage != null) {
                      setState(() => errorMessage = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: AppStrings.isArabic ? 'المبلغ المدفوع الآن' : 'Amount Paid Now',
                    border: const OutlineInputBorder(),
                    errorText: errorMessage,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPaid = double.tryParse(controller.text) ?? 0;

                  if (newPaid <= 0) {
                    setState(() {
                      errorMessage = AppStrings.isArabic
                          ? 'يرجى إدخال مبلغ أكبر من 0'
                          : 'Please enter an amount greater than 0';
                    });
                    return;
                  }

                  if (newPaid > remaining) {
                    setState(() {
                      errorMessage = AppStrings.isArabic
                          ? 'المبلغ يتخطى المتبقي (${remaining.toStringAsFixed(0)} ج.م)'
                          : 'Amount exceeds remaining balance';
                    });
                    return;
                  }

                  cubit.updateInvoice(invoice.copyWith(
                    paidAmount: invoice.paidAmount + newPaid,
                  ));
                  Navigator.pop(context);
                },
                child: Text(AppStrings.save),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _getLocalPaymentMethod(String? method) {
    if (method == 'cash') return AppStrings.isArabic ? 'نقد' : 'Cash';
    if (method == 'card') return AppStrings.isArabic ? 'بطاقة' : 'Card';
    if (method == 'bank') return AppStrings.isArabic ? 'تحويل' : 'Transfer';
    return method ?? (AppStrings.isArabic ? 'نقد' : 'Cash');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption(context)),
          Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
