import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddClinicUseCase {
  final ClinicsRepository clinicsRepository;

  AddClinicUseCase({required this.clinicsRepository});
  Future<Either<Failure, void>> call(ClinicEntity clinic) {
    return clinicsRepository.addClinic(clinic);
  }
}
