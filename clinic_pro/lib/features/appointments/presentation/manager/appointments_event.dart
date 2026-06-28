// ────────────────────────────────────────────────────────
// أحداث Bloc شاشة المواعيد
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'appointments_state.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentsEvent {}

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

  const AddAppointmentEvent({
    required this.patientId,
    required this.doctorId,
    required this.typeId,
    required this.date,
    required this.time,
    this.notes,
    this.isUrgent = false,
  });

  @override
  List<Object?> get props =>
      [patientId, doctorId, typeId, date, time, notes, isUrgent];
}
