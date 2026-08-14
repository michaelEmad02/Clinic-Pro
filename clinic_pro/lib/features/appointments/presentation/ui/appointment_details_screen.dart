// ────────────────────────────────────────────────────────
// شاشة تفاصيل الموعد — مطابقة لتصميم Stitch ومتجاوبة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../manager/appointments_bloc.dart';
import '../manager/appointments_event.dart';
import '../manager/appointments_state.dart';
import 'widgets/appointment_header_card.dart';
import 'widgets/appointment_status_timeline.dart';
import 'widgets/linked_invoice_card.dart';
import 'widgets/linked_prescription_card.dart';
import 'widgets/urgent_appointment_banner.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String id;

  const AppointmentDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is! AppointmentsLoaded) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.appointmentDetails)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final appointments = state.allAppointments;
        final appointment = appointments.firstWhere(
          (a) => a.id == id,
          
        );

        if (appointment.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.appointmentDetails)),
            body: Center(
              child: Text(AppStrings.appointmentNotFound),
            ),
          );
        }

        final canCancel =
            appointment.status != AppointmentStatus.done && appointment.status != AppointmentStatus.cancelled;

        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            toolbarHeight: 64,
            backgroundColor: context.surfaceColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              AppStrings.appointmentDetails,
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: context.borderColor, height: 1),
            ),
          ),
          body: ResponsiveHelper.responsiveCenter(
            maxWidth: AppConstants.maxContentWidth,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
              children: [
                AppointmentStatusTimeline(appointment: appointment),
                if (appointment.isUrgent) ...[
                  const SizedBox(height: AppConstants.spaceSm + 4),
                  const UrgentAppointmentBanner(),
                ],
                const SizedBox(height: AppConstants.spaceMd),
                AppointmentHeaderCard(appointment: appointment),
                const SizedBox(height: AppConstants.spaceMd),
                if (appointment.status != AppointmentStatus.scheduled)
                  LinkedPrescriptionCard(
                    hasPrescription: appointment.hasPrescription,
                    diagnosis: appointment.prescriptionDiagnosis,
                    appointmentId: appointment.id,
                    appointment: appointment,
                  ),
                const SizedBox(height: AppConstants.spaceMd),
                LinkedInvoiceCard(
                  hasInvoice: appointment.hasInvoice,
                  amount: appointment.invoiceAmount,
                  status: appointment.invoiceStatus,
                  invoiceNumber: appointment.invoiceNumber,
                  appointmentId: appointment.id,
                ),
                if (canCancel) ...[
                  const SizedBox(height: AppConstants.spaceLg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<AppointmentsBloc>()
                            .add(CancelAppointmentEvent(appointment.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppStrings.appointmentDeleted)),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.cancel_outlined, color: context.danger),
                      label: Text(
                        '${AppStrings.cancel} ${AppStrings.appointment}',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spaceLg),
              ],
            ),
          ),
        );
      },
    );
  }
}
