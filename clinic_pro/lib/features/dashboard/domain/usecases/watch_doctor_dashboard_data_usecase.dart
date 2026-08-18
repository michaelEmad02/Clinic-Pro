import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/doctor_dashboard_data_entity.dart';
import '../repositories/i_doctor_dashboard_repository.dart';
import 'get_doctor_dashboard_data_usecase.dart';

@lazySingleton
class WatchDoctorDashboardDataUseCase {
  final IDoctorDashboardRepository _repository;

  WatchDoctorDashboardDataUseCase(this._repository);

  Stream<Either<Failure, DoctorDashboardDataEntity>> call(
    GetDoctorDashboardDataParams params,
  ) {
    return _repository.watchDoctorDashboardData(
      doctorId: params.doctorId,
      clinicId: params.clinicId,
      doctorName: params.doctorName,
      clinicName: params.clinicName,
    );
  }
}
