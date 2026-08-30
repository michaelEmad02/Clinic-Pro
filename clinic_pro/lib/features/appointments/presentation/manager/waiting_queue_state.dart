// ────────────────────────────────────────────────────────
// حالات شاشة طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:equatable/equatable.dart';

class QueuePatient extends Equatable {
  final String id;
  final String patientName;
  final String typeName;
  final String displayTime;
  final String status;
  final bool isUrgent;
  final int queueNumber;
  final DateTime? arrivedAt;
  final String? patientPhone;
  final String? patientId;
  final String? doctorName;

  const QueuePatient({
    required this.id,
    required this.patientName,
    required this.typeName,
    required this.displayTime,
    required this.status,
    required this.isUrgent,
    required this.queueNumber,
    this.arrivedAt,
    this.patientPhone,
    this.patientId,
    this.doctorName,
  });

  QueuePatient copyWith({
    String? status,
    int? queueNumber,
    DateTime? arrivedAt,
    String? patientPhone,
    String? patientId,
    String? doctorName,
  }) {
    return QueuePatient(
      id: id,
      patientName: patientName,
      typeName: typeName,
      displayTime: displayTime,
      status: status ?? this.status,
      isUrgent: isUrgent,
      queueNumber: queueNumber ?? this.queueNumber,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      patientPhone: patientPhone ?? this.patientPhone,
      patientId: patientId ?? this.patientId,
      doctorName: doctorName ?? this.doctorName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        queueNumber,
        arrivedAt,
        patientPhone,
        patientId,
        doctorName,
      ];
}

abstract class WaitingQueueState extends Equatable {
  const WaitingQueueState();

  @override
  List<Object?> get props => [];
}

class WaitingQueueInitial extends WaitingQueueState {}

class WaitingQueueLoading extends WaitingQueueState {}

class WaitingQueueLoaded extends WaitingQueueState {
  final List<QueuePatient> queue;
  final List<AppointmentEntity> rawQueue;
  final AppointmentEntity? currentPatient;
  final String doctorName;

  const WaitingQueueLoaded({
    required this.queue,
    this.rawQueue = const [],
    this.currentPatient,
    required this.doctorName,
  });

  WaitingQueueLoaded copyWith({
    List<QueuePatient>? queue,
    List<AppointmentEntity>? rawQueue,
    AppointmentEntity? currentPatient,
  }) {
    return WaitingQueueLoaded(
      queue: queue ?? this.queue,
      rawQueue: rawQueue ?? this.rawQueue,
      currentPatient: currentPatient ?? this.currentPatient,
      doctorName: doctorName,
    );
  }

  @override
  List<Object?> get props => [queue, rawQueue, currentPatient, doctorName];
}

class WaitingQueueError extends WaitingQueueState {
  final String message;

  const WaitingQueueError(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientCalledSuccessfully extends WaitingQueueState {
  final AppointmentEntity appointment; // AppointmentEntity
  const PatientCalledSuccessfully(this.appointment);

  @override
  List<Object?> get props => [appointment];
}
