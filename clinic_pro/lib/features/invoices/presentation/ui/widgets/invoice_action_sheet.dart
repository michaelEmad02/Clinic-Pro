// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الفاتورة (···) + تسديد دفعة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/invoices_cubit.dart';
import '../../manager/invoices_state.dart';
import 'add_invoice_sheet.dart';

class InvoiceActionSheet {
  static Future<void> show({
    required BuildContext context,
    required InvoiceItem invoice,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice.patientName,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              invoice.appointmentType,
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
                  ? context.successText
                  : context.warningText,
            ),
            _DetailRow(
              label: AppStrings.paymentMethod,
              value: invoice.paymentMethodLabel,
            ),
            _DetailRow(
              label: AppStrings.date,
              value: invoice.formattedDate,
            ),
            _DetailRow(
              label: AppStrings.status,
              value: invoice.statusLabel,
            ),
            const SizedBox(height: 16),
            if (invoice.paidAmount < invoice.totalAmount)
              _ActionTile(
                icon: Icons.payment,
                label: AppStrings.isArabic ? 'تسديد دفعة' : 'Make Payment',
                color: context.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showPaymentSheet(context, invoice);
                },
              ),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: AppStrings.isArabic ? 'تعديل الفاتورة' : 'Edit Invoice',
              color: context.primary,
              onTap: () {
                Navigator.pop(context);
                AddInvoiceSheet.show(context,
                    initialAppointmentId: invoice.sourceId, invoice: invoice);
              },
            ),
            _ActionTile(
              icon: Icons.print_outlined,
              label: '${AppStrings.print} ${AppStrings.invoice}',
              color: context.textSecondary,
              onTap: () => Navigator.pop(context),
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: AppStrings.isArabic ? 'حذف الفاتورة' : 'Delete Invoice',
              color: context.danger,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, invoice);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, InvoiceItem invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.confirmDelete,
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(
          AppStrings.isArabic ? 'هل أنت متأكد من حذف هذه الفاتورة نهائياً؟ هذا الإجراء سيؤثر على التقارير المالية للعيادة ولا يمكن التراجع عنه.' : 'Are you sure you want to permanently delete this invoice? This will affect financial reports and cannot be undone.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel,
                style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InvoicesCubit>().deleteInvoice(invoice.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.invoiceDeleted)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.danger),
            child: Text(AppStrings.delete,
                style:
                    const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPaymentSheet(
      BuildContext context, InvoiceItem invoice) {
    final remaining = invoice.totalAmount - invoice.paidAmount;
    final amountController =
        TextEditingController(text: remaining.toStringAsFixed(0));
    String selectedMethod = invoice.paymentMethod ?? 'cash';

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.isArabic ? 'تسديد دفعة' : 'Make Payment',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.isArabic ? 'المبلغ المتبقي: ${remaining.toStringAsFixed(0)} ${AppStrings.egp}' : 'Remaining: ${remaining.toStringAsFixed(0)} ${AppStrings.egp}',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        AppStrings.egp,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  fillColor: context.surfaceContainerLow,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _methodChip(ctx, 'cash', '💵', AppStrings.cash, selectedMethod,
                      (v) {
                    selectedMethod = v;
                    (ctx as Element).markNeedsBuild();
                  }),
                  const SizedBox(width: 8),
                  _methodChip(ctx, 'card', '💳', AppStrings.card, selectedMethod,
                      (v) {
                    selectedMethod = v;
                    (ctx as Element).markNeedsBuild();
                  }),
                  const SizedBox(width: 8),
                  _methodChip(ctx, 'bank', '🔄', AppStrings.transfer, selectedMethod,
                      (v) {
                    selectedMethod = v;
                    (ctx as Element).markNeedsBuild();
                  }),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(AppStrings.isArabic ? 'يرجى إدخال مبلغ صحيح' : 'Please enter a valid amount')),
                      );
                      return;
                    }
                    final newPaid = (invoice.paidAmount + amount)
                        .clamp(0, invoice.totalAmount)
                        .toDouble();
                    context.read<InvoicesCubit>().updatePaidAmount(
                          invoiceId: invoice.id,
                          newPaidAmount: newPaid,
                          paymentMethod: selectedMethod,
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.operationSuccessful)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: context.primary.withOpacity(0.3),
                  ),
                  child: Text(
                    AppStrings.confirm,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _methodChip(
    BuildContext context,
    String value,
    String emoji,
    String label,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    final isSelected = selected == value;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onChanged(value),
        selectedColor: context.primary,
        backgroundColor: context.surface,
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: isSelected ? Colors.white : context.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? context.primary : context.border,
          ),
        ),
        showCheckmark: false,
      ),
    );
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
          Text(
            label,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: (AppStrings.isArabic || value.contains('ج.م')) ? 'Cairo' : 'Inter',
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
