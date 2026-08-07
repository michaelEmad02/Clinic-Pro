// ────────────────────────────────────────────────────────
// أحداث Bloc شاشة المواعيد
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:equatable/equatable.dart';
import 'appointments_state.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentsEvent {
  final String doctorId;
  final String? clinicId;

  const LoadAppointmentsEvent({required this.doctorId, this.clinicId});
}

class SubscribeAppointmentsEvent extends AppointmentsEvent {
  final String doctorId;
  final String? clinicId;

  const SubscribeAppointmentsEvent({required this.doctorId, this.clinicId});
}

class RefreshAppointmentsEvent extends AppointmentsEvent {
  final List<AppointmentEntity> appointments;

  const RefreshAppointmentsEvent(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class ChangeAppointmentsTabEvent extends AppointmentsEvent {
  final AppointmentsTab tab;

  const ChangeAppointmentsTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class ChangeStatusFilterEvent extends AppointmentsEvent {
  final String filter;

  const ChangeStatusFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ConfirmArrivalEvent extends AppointmentsEvent {
  final String appointmentId;

  const ConfirmArrivalEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class CancelAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;

  const CancelAppointmentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class ToggleUrgentEvent extends AppointmentsEvent {
  final String appointmentId;

  const ToggleUrgentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class AddAppointmentEvent extends AppointmentsEvent {
  final String patientId;
  final String doctorId;
  final String typeId;
  final String date;
  final String time;
  final String? notes;
  final bool isUrgent;
  final String currentUser;

  const AddAppointmentEvent({
    required this.patientId,
    required this.doctorId,
    required this.typeId,
    required this.date,
    required this.time,
    this.notes,
    this.isUrgent = false,
    required this.currentUser,
  });

  @override
  List<Object?> get props =>
      [patientId, doctorId, typeId, date, time, notes, isUrgent];
}

/// حدث تعديل بيانات موعد قائم (النوع، الطبيب، التاريخ، الوقت، الملاحظات، الاستعجال)
class UpdateAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;
  final String doctorId;
  final String typeId;
  final String date;
  final String time;
  final String? notes;
  final bool isUrgent;

  const UpdateAppointmentEvent({
    required this.appointmentId,
    required this.doctorId,
    required this.typeId,
    required this.date,
    required this.time,
    this.notes,
    this.isUrgent = false,
  });

  @override
  List<Object?> get props =>
      [appointmentId, doctorId, typeId, date, time, notes, isUrgent];
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;

  const DeleteAppointmentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class GetAppointmentDetailsEvent extends AppointmentsEvent {
  final String appointmentId;

  const GetAppointmentDetailsEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

/// حدث إنهاء الزيارة بعد حفظ الروشتة — يغير الحالة إلى done ويضع called_at إذا كانت فارغة
class CompleteAppointmentEvent extends AppointmentsEvent {
  final String appointmentId;
  final DateTime? calledAt;

  const CompleteAppointmentEvent({
    required this.appointmentId,
    this.calledAt,
  });

  @override
  List<Object?> get props => [appointmentId, calledAt];
}
