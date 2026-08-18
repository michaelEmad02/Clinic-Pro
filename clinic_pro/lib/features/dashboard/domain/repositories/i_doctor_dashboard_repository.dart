import 'package:dartz/dartz.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/doctor_dashboard_data_entity.dart';

/// واجهة مستودع لوحة تحكم الطبيب (Domain Repository Interface)
abstract class IDoctorDashboardRepository {
  Future<Either<Failure, DoctorDashboardDataEntity>> getDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  });

  Stream<Either<Failure, DoctorDashboardDataEntity>> watchDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  });

  Future<Either<Failure, void>> callNextPatient({
    required String appointmentId,
  });
}
