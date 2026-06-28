// ────────────────────────────────────────────────────────
// حالات شاشة طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class QueuePatient extends Equatable {
  final String id;
  final String patientName;
  final String typeName;
  final String displayTime;
  final String status;
  final bool isUrgent;
  final int queueNumber;

  const QueuePatient({
    required this.id,
    required this.patientName,
    required this.typeName,
    required this.displayTime,
    required this.status,
    required this.isUrgent,
    required this.queueNumber,
  });

  QueuePatient copyWith({String? status, int? queueNumber}) {
    return QueuePatient(
      id: id,
      patientName: patientName,
      typeName: typeName,
      displayTime: displayTime,
      status: status ?? this.status,
      isUrgent: isUrgent,
      queueNumber: queueNumber ?? this.queueNumber,
    );
  }

  @override
  List<Object?> get props => [id, status, queueNumber];
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
  final String doctorName;

  const WaitingQueueLoaded({
    required this.queue,
    required this.doctorName,
  });

  WaitingQueueLoaded copyWith({List<QueuePatient>? queue}) {
    return WaitingQueueLoaded(
      queue: queue ?? this.queue,
      doctorName: doctorName,
    );
  }

  @override
  List<Object?> get props => [queue, doctorName];
}

class WaitingQueueError extends WaitingQueueState {
  final String message;

  const WaitingQueueError(this.message);

  @override
  List<Object?> get props => [message];
}
