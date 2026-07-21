import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/clinics/data/data_sources/clinics_remote_data_source.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_statistics_entity.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:dartz/dartz.dart';

import 'package:clinic_pro/features/clinics/data/models/clinic_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ClinicsRepository)
class ClinicsRepoImplementation extends ClinicsRepository {
  final IClinicsRemoteDataSource iClinicsRemoteDataSource;

  ClinicsRepoImplementation({required this.iClinicsRemoteDataSource});
  @override
  Future<Either<Failure, String>> addClinic(ClinicEntity clinic) async {
    try {
      final model = ClinicModel(
        id: clinic.id,
        ownerId: clinic.ownerId,
        name: clinic.name,
        address: clinic.address,
        phone1: clinic.phone1,
        phone2: clinic.phone2,
        logoUrl: clinic.logoUrl,
        isActive: clinic.isActive,
        createdAt: clinic.createdAt,
      );
      final id = await iClinicsRemoteDataSource.addClinic(model);
      return Right(id);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> addStaff(
      String clinicId, String staffId, String? doctorId, StaffRoles role) async {
    try {
      await iClinicsRemoteDataSource.addStaff(
          clinicId, staffId, doctorId, role);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClinic(String id) async {
    try {
      await iClinicsRemoteDataSource.deleteClinic(id);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStaff(
      String clinicId, String staffId, [String? doctorId]) async {
    try {
      await iClinicsRemoteDataSource.deleteStaff(clinicId, staffId, doctorId);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> editClinic(ClinicEntity clinic) async {
    try {
      final model = ClinicModel(
        id: clinic.id,
        ownerId: clinic.ownerId,
        name: clinic.name,
        address: clinic.address,
        phone1: clinic.phone1,
        phone2: clinic.phone2,
        logoUrl: clinic.logoUrl,
        isActive: clinic.isActive,
        createdAt: clinic.createdAt,
      );
      await iClinicsRemoteDataSource.editClinic(model);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClinicEntity>> fetchClinicById(String id) async {
    try {
      final clinic = await iClinicsRemoteDataSource.fetchClinicById(id);
      return Right(clinic);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClinicStatisticsEntity>> fetchClinicStatistics(
      String clinicId) async {
    try {
      final stats =
          await iClinicsRemoteDataSource.fetchClinicStatistics(clinicId);
      return Right(stats);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClinicEntity>>> fetchClinics(
      String ownerId) async {
    try {
      final clinics = await iClinicsRemoteDataSource.fetchClinics(ownerId);
      return Right(clinics);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleIsActive(String id, bool isActive) async {
    try {
      await iClinicsRemoteDataSource.toggleIsActive(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<StaffEntity>>> fetchClinicStaff(
      String clinicId) async {
    try {
      var result = await iClinicsRemoteDataSource.fetchClinicStaff(clinicId);
      return right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
