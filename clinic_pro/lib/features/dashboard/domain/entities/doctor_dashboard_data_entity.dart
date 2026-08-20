import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

/// كيان بيانات لوحة تحكم الطبيب (Doctor Dashboard Data Entity)
/// يحتوي على الإحصائيات الحالية والمريض المعالج وطابور الانتظار
class DoctorDashboardDataEntity extends Equatable {
  final String doctorName;
  final String clinicName;
  final AppointmentEntity? currentPatient;
  final List<AppointmentEntity> waitingQueue;
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;
  final double todayRevenue;
  final double collectedAmount;

  const DoctorDashboardDataEntity({
    required this.doctorName,
    required this.clinicName,
    this.currentPatient,
    required this.waitingQueue,
    required this.todayAppointmentsCount,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
    required this.todayRevenue,
    required this.collectedAmount,
  });

  @override
  List<Object?> get props => [
        doctorName,
        clinicName,
        currentPatient,
        waitingQueue,
        todayAppointmentsCount,
        completedCount,
        waitingCount,
        avgWaitingTime,
        todayRevenue,
        collectedAmount,
      ];
}
