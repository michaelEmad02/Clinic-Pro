// ────────────────────────────────────────────────────────
// UnbilledAppointmentsList — قائمة المواعيد غير المفوترة مع إمكانية التفوتر المباشر
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:clinic_pro/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:clinic_pro/features/invoices/presentation/ui/widgets/add_invoice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:clinic_pro/core/widgets/empty_state.dart';

class UnbilledAppointmentsList extends StatelessWidget {
  final List<UnpaidAppointmentEntity> appointments;

  const UnbilledAppointmentsList({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyState(
        title: AppStrings.isArabic
            ? 'جميع المواعيد مفوترة بالكامل'
            : 'All Visits Billed',
        subtitle: AppStrings.isArabic
            ? 'لا توجد زيارات معلقة تنتظر التحصيل حالياً'
            : 'No pending visits awaiting billing at the moment',
        icon: Icons.check_circle_outline,
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appt = appointments[index];
          return _UnbilledAppointmentCard(appointment: appt);
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520,
        mainAxisExtent: 110,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: appointments.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return _UnbilledAppointmentCard(appointment: appt);
      },
    );
  }
}

class _UnbilledAppointmentCard extends StatelessWidget {
  final UnpaidAppointmentEntity appointment;

  const _UnbilledAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final margin = isMobile
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
        : EdgeInsets.zero;

    final remainingToBill = appointment.expectedPrice - appointment.paidSoFar;

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
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.patientName ?? AppStrings.unknownPatient,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${appointment.date} • ${appointment.appointmentTypeName ?? (AppStrings.isArabic ? "كشف عام" : "General Checkup")}',
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppStrings.isArabic ? 'بانتظار التفوتر' : 'Awaiting Invoice',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.warning,
                          ),
                        ),
                      ),
                      if (appointment.paidSoFar > 0)
                        Text(
                          '(${AppStrings.isArabic ? "مسدد جزئياً" : "Partially Paid"}: ${appointment.paidSoFar.toStringAsFixed(0)} ${AppStrings.egp})',
                          style: AppTextStyles.caption(context).copyWith(
                            fontSize: 10,
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${remainingToBill.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.danger,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () async {
                    await AddInvoiceSheet.show(
                      context,
                      initialAppointmentId: appointment.id,
                    );
                    if (context.mounted) {
                      final cubit = context.read<InvoicesCubit>();
                      final state = cubit.state;
                      if (state.invoices.isNotEmpty) {
                        cubit.loadInvoices(state.invoices.first.clinicId);
                      }
                    }
                  },
                  icon: const Icon(Icons.receipt_long, size: 13),
                  label: Text(
                    AppStrings.isArabic ? 'أصدر فاتورة' : 'Create Invoice',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primary,
                    side: BorderSide(color: context.primary.withOpacity(0.3)),
                    backgroundColor: context.primaryLightColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
