// ────────────────────────────────────────────────────────
// بطاقة الفاتورة المرتبطة بالموعد — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../../invoices/domain/entities/invoice_entity.dart';
import '../../../../invoices/presentation/ui/widgets/add_invoice_sheet.dart';
import '../../manager/appointments_bloc.dart';
import '../../manager/appointments_event.dart';
import '../../manager/appointments_state.dart';

class LinkedInvoiceCard extends StatelessWidget {
  final bool hasInvoice;
  final String? amount;
  final String? status;
  final String? invoiceNumber;
  final String? appointmentId;
  final List<InvoiceEntity>? invoices;

  const LinkedInvoiceCard({
    super.key,
    required this.hasInvoice,
    this.amount,
    this.status,
    this.invoiceNumber,
    this.appointmentId,
    this.invoices,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'paid';

    List<dynamic> invoicesList = invoices ?? [];
    if (invoicesList.isEmpty && invoiceNumber != null && invoiceNumber!.isNotEmpty) {
      try {
        invoicesList = jsonDecode(invoiceNumber!);
      } catch (_) {}
    }

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
              Icon(Icons.receipt_long_outlined, color: context.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.invoice,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
              ),
              if (hasInvoice)
                StatusBadge(
                  text: isPaid ? AppStrings.paid : (AppStrings.isArabic ? 'جزئي' : 'Partial'),
                  status: isPaid ? BadgeStatus.success : BadgeStatus.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasInvoice) ...[
            if (invoicesList.isNotEmpty) ...[
              ...invoicesList.map((inv) {
                final double total = inv is InvoiceEntity
                    ? inv.totalAmount
                    : ((inv['total_amount'] as num?)?.toDouble() ?? 0.0);
                final double paid = inv is InvoiceEntity
                    ? inv.paidAmount
                    : ((inv['paid_amount'] as num?)?.toDouble() ?? 0.0);
                final DateTime? rawDate = inv is InvoiceEntity
                    ? inv.createdAt
                    : DateTime.tryParse((inv['created_at'] as String?) ?? '');
                // Supabase يحفظ بـ UTC — نضمن تفسيرها كـ UTC
                final parsedDate = rawDate != null && !rawDate.isUtc
                    ? DateTime.utc(rawDate.year, rawDate.month, rawDate.day,
                        rawDate.hour, rawDate.minute, rawDate.second)
                    : rawDate;
                final dateFormatted = parsedDate != null
                    ? '${parsedDate.toLocal().day}/${parsedDate.toLocal().month}/${parsedDate.toLocal().year}'
                    : '';
                final creatorName = (inv is InvoiceEntity
                        ? inv.createdByName
                        : (inv['creator_name'] as String?)) ??
                    (AppStrings.isArabic ? 'غير معروف' : 'Unknown');
                
                final statusStr = paid >= total
                    ? (AppStrings.isArabic ? 'مدفوعة' : 'Paid')
                    : (paid > 0 ? (AppStrings.isArabic ? 'جزئية' : 'Partial') : (AppStrings.isArabic ? 'معلقة' : 'Pending'));
                final localStatusColor = paid >= total
                    ? context.success
                    : (paid > 0 ? context.warning : context.danger);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormatted,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${paid.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} ${AppStrings.egp}',
                            style: AppTextStyles.dataNumeric(context).copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: localStatusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusStr,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: localStatusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.isArabic ? "بواسطة" : "By"}: $creatorName',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 16),
            ],
            if (amount != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.isArabic ? 'الإجمالي الكلي:' : 'Total Aggregate:',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    '$amount ${AppStrings.egp}',
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPaid ? context.success : context.warning,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Text(
              AppStrings.noInvoiceYet,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          if (!isPaid) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                if (appointmentId != null) {
                  await AddInvoiceSheet.show(context, initialAppointmentId: appointmentId);
                  if (context.mounted) {
                    final bloc = context.read<AppointmentsBloc>();
                    final state = bloc.state;
                    if (state is AppointmentsLoaded) {
                      final appt = state.allAppointments.firstWhere((a) => a.id == appointmentId);
                      bloc.add(LoadAppointmentsEvent(
                        doctorId: appt.doctorId,
                        clinicId: appt.clinicId,
                      ));
                    }
                  }
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(hasInvoice ? (AppStrings.isArabic ? 'تسجيل فاتورة إضافية' : 'Create Additional Invoice') : AppStrings.createInvoice),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primary,
                side: BorderSide(color: context.primary.withOpacity(0.2)),
                backgroundColor: context.primaryLightColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
