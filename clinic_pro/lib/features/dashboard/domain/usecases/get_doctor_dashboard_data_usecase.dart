import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/doctor_dashboard_data_entity.dart';
import '../repositories/i_doctor_dashboard_repository.dart';

class GetDoctorDashboardDataParams {
  final String doctorId;
  final String clinicId;
  final String? doctorName;
  final String? clinicName;

  const GetDoctorDashboardDataParams({
    required this.doctorId,
    required this.clinicId,
    this.doctorName,
    this.clinicName,
  });
}

@lazySingleton
class GetDoctorDashboardDataUseCase {
  final IDoctorDashboardRepository _repository;

  GetDoctorDashboardDataUseCase(this._repository);

  Future<Either<Failure, DoctorDashboardDataEntity>> call(
    GetDoctorDashboardDataParams params,
  ) {
    return _repository.getDoctorDashboardData(
      doctorId: params.doctorId,
      clinicId: params.clinicId,
      doctorName: params.doctorName,
      clinicName: params.clinicName,
    );
  }
}
