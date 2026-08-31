// ────────────────────────────────────────────────────────
// تنفيذ مستودع المرضى (PatientsRepositoryImpl)
// يتعامل مع IPatientsRemoteDataSource ويقوم بتحويل البيانات إلى كيانات
// يلتف على الأخطاء بنمط Either<Failure, T>
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../prescription/domain/entities/prescription_entity.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/i_patients_repository.dart';
import '../datasources/i_patients_remote_data_source.dart';
import '../models/patient_model.dart';

@LazySingleton(as: IPatientsRepository)
class PatientsRepositoryImpl implements IPatientsRepository {
  final IPatientsRemoteDataSource _remoteDataSource;

  PatientsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PatientEntity>>> getPatients({
    required String clinicId,
  }) async {
    try {
      final models = await _remoteDataSource.getPatients(clinicId: clinicId);
      return Right(models);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> getPatientById(String id) async {
    try {
      final model = await _remoteDataSource.getPatientById(id);
      return Right(model);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> addPatient(
    PatientEntity patient,
  ) async {
    try {
      final model = PatientModel.fromEntity(patient);
      final result = await _remoteDataSource.insertPatient(model);
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> updatePatient(
    PatientEntity patient,
  ) async {
    try {
      final model = PatientModel.fromEntity(patient);
      final result = await _remoteDataSource.updatePatient(model);
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePatient(String id) async {
    try {
      await _remoteDataSource.deletePatient(id);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getVisitsForPatient(
    String patientId,
  ) async {
    try {
      final visits = await _remoteDataSource.getVisitsForPatient(patientId);
      return Right(visits);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptionsForPatient(String patientId,
  ) async {
    try {
      final models = await _remoteDataSource.getPrescriptionsForPatient(patientId);
      if (models.isEmpty) return const Right([]);

      final List<PrescriptionEntity> result = [];

      for (final model in models) {
        result.add(PrescriptionEntity(
          id: model.id,
          createdAt: model.createdAt,
          clinicId: model.clinicId,
          doctorId: model.doctorId,
          patientId: model.patientId,
          appointmentId: model.appointmentId,
          diagnosis: model.diagnosis,
          diagnoses: model.diagnoses,
          notes: model.notes,
          nextVisitDays: model.nextVisitDays,
          items: model.items,
        ));
      }

      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
