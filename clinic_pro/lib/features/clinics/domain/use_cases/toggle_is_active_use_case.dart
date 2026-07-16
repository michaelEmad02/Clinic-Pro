import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ToggleIsActiveUseCase {
  final ClinicsRepository clinicsRepository;

  ToggleIsActiveUseCase({required this.clinicsRepository});
  Future<Either<Failure, void>> call(String id, bool isActive) {
    return clinicsRepository.toggleIsActive(id, isActive);
  }
}
