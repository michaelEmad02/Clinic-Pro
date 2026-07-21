import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchClinicStaffUseCase {
  final ClinicsRepository clinicsRepository;

  FetchClinicStaffUseCase({required this.clinicsRepository});

  Future<Either<Failure, List<StaffEntity>>> call(String clinicId) {
    return clinicsRepository.fetchClinicStaff(clinicId);
  }
}
