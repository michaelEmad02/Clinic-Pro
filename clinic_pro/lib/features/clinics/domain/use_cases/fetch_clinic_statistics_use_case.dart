import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_statistics_entity.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchClinicStatisticsUseCase {
  final ClinicsRepository clinicsRepository;

  FetchClinicStatisticsUseCase({required this.clinicsRepository});

  Future<Either<Failure, ClinicStatisticsEntity>> call(String clinicId) {
    return clinicsRepository.fetchClinicStatistics(clinicId);
  }
}
