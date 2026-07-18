import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteStaffUseCase {
  final ClinicsRepository clinicsRepository;

  DeleteStaffUseCase({required this.clinicsRepository});

  Future<Either<Failure, void>> call(String clinicId, String staffId, [String? doctorId]) {
    return clinicsRepository.deleteStaff(clinicId, staffId, doctorId);
  }
}
