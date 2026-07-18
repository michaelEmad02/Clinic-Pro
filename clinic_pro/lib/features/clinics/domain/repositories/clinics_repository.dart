import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_statistics_entity.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ClinicsRepository {
  Future<Either<Failure, List<ClinicEntity>>> fetchClinics(String ownerId);
  Future<Either<Failure, ClinicEntity>> fetchClinicById(String id);

  Future<Either<Failure, List<StaffEntity>>> fetchClinicStaff(String clinicId);
  Future<Either<Failure, void>> addClinic(ClinicEntity clinic);
  Future<Either<Failure, void>> editClinic(ClinicEntity clinic);
  Future<Either<Failure, void>> deleteClinic(String id);
  Future<Either<Failure, void>> toggleIsActive(String id, bool isActive);
  Future<Either<Failure, void>> addStaff(
      String clinicId,
      String staffId,
      String? doctorId,
      StaffRoles
          role); // if the staff is new , will create it by use staff feature
  Future<Either<Failure, void>> deleteStaff(String clinicId, String staffId, [String? doctorId]);
  Future<Either<Failure, ClinicStatisticsEntity>> fetchClinicStatistics(
      String clinicId);
}
