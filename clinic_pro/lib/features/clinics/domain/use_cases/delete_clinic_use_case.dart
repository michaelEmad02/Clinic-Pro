import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteClinicUseCase {
  final ClinicsRepository clinicsRepository;

  DeleteClinicUseCase({required this.clinicsRepository});

  Future<Either<Failure, void>> call(String id) {
    return clinicsRepository.deleteClinic(id);
  }
}
