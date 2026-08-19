import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../manager/appointments_bloc.dart';
import '../../manager/appointments_event.dart';
import 'appointment_action_sheet.dart';
import '../../../../invoices/presentation/ui/widgets/add_invoice_sheet.dart';
import 'add_appointment_sheet.dart';

class AppointmentDialogs {
  static void showActions({
    required BuildContext context,
    required AppointmentEntity item,
    required AppointmentsBloc bloc,
    required String clinicId,
    required String doctorId,
  }) {
    AppointmentActionSheet.show(
      context: context,
      appointment: item,
      onConfirmArrival: item.status == AppointmentStatus.scheduled
          ? () => bloc.add(ConfirmArrivalEvent(item.id))
          : null,
      onComplete: item.status != AppointmentStatus.done &&
              item.status != AppointmentStatus.cancelled
          ? () => confirmComplete(context: context, item: item, bloc: bloc)
          : null,
      onToggleUrgent: () => bloc.add(ToggleUrgentEvent(item.id)),
      onCancel: item.status != AppointmentStatus.done && item.status != AppointmentStatus.cancelled
          ? () => confirmCancel(context: context, item: item, bloc: bloc)
          : null,
      onRegisterInvoice: () async {
        await AddInvoiceSheet.show(context, initialAppointmentId: item.id);
        if (context.mounted) {
          bloc.add(LoadAppointmentsEvent(doctorId: doctorId, clinicId: clinicId));
        }
      },
      onViewDetails: () => context.push('${RouteConstants.appointments}/${item.id}'),
      onEdit: () async {
        await AddAppointmentSheet.show(context, appointment: item);
        if (context.mounted) {
          bloc.add(LoadAppointmentsEvent(doctorId: doctorId, clinicId: clinicId));
        }
      },
      onDelete: () => confirmDelete(context: context, item: item, bloc: bloc),
    );
  }

  static void confirmComplete({
    required BuildContext context,
    required AppointmentEntity item,
    required AppointmentsBloc bloc,
  }) {
    if (item.status == AppointmentStatus.inProgress) {
      bloc.add(CompleteAppointmentEvent(appointmentId: item.id));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.isArabic ? 'تأكيد إتمام الموعد' : 'Confirm Complete Appointment'),
        content: Text(
          AppStrings.isArabic
              ? 'تنبيه: هذا الموعد ليس في حالة "قيد الكشف". هل أنت تأكد من رغبتك في إتمام الزيارة مباشرة؟'
              : 'Warning: This appointment is not in progress. Are you sure you want to complete the visit directly?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(CompleteAppointmentEvent(appointmentId: item.id));
            },
            style: TextButton.styleFrom(foregroundColor: context.success),
            child: Text(AppStrings.isArabic ? 'إتمام الموعد' : 'Complete Appointment'),
          ),
        ],
      ),
    );
  }

  static void confirmCancel({
    required BuildContext context,
    required AppointmentEntity item,
    required AppointmentsBloc bloc,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppStrings.cancel} ${AppStrings.appointment}'),
        content: Text(AppStrings.cancelAppointmentWithInvoice(item.hasInvoice)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(CancelAppointmentEvent(item.id));
            },
            style: TextButton.styleFrom(foregroundColor: context.danger),
            child: Text(AppStrings.confirmCancel),
          ),
        ],
      ),
    );
  }

  static void confirmDelete({
    required BuildContext context,
    required AppointmentEntity item,
    required AppointmentsBloc bloc,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAppointmentTitle),
        content: Text(AppStrings.confirmDeleteAppointmentMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(DeleteAppointmentEvent(item.id));
            },
            style: TextButton.styleFrom(foregroundColor: context.danger),
            child: Text(AppStrings.confirmDelete),
          ),
        ],
      ),
    );
  }
}
