import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddStaffUseCase {
  final ClinicsRepository clinicsRepository;

  AddStaffUseCase({required this.clinicsRepository});
  Future<Either<Failure, void>> call(
      String clinicId, String staffId, String doctorId, StaffRoles role) {
    return clinicsRepository.addStaff(clinicId, staffId, doctorId, role);
  }
}
