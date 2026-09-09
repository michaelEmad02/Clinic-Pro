// ────────────────────────────────────────────────────────
// تطبيق مستودع السجلات الطبية (MedicalRecordsRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/repositories/i_medical_records_repository.dart';
import '../datasources/i_medical_records_remote_data_source.dart';

@LazySingleton(as: IMedicalRecordsRepository)
class MedicalRecordsRepositoryImpl implements IMedicalRecordsRepository {
  final IMedicalRecordsRemoteDataSource _remoteDataSource;

  MedicalRecordsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MedicalRecordEntity>>> getMedicalRecords({
    required String patientId,
    String? type,
  }) async {
    try {
      final records = await _remoteDataSource.getMedicalRecords(
        patientId: patientId,
        type: type,
      );
      return Right(records);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<MedicalRecordEntity>>> getRecordsForAppointment({
    required String appointmentId,
  }) async {
    try {
      final records = await _remoteDataSource.getRecordsForAppointment(
        appointmentId: appointmentId,
      );
      return Right(records);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> uploadMedicalRecord({
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    required String type,
    required String title,
    required File imageFile,
    required String recordDate,
    String? notes,
  }) async {
    try {
      final record = await _remoteDataSource.uploadMedicalRecord(
        clinicId: clinicId,
        patientId: patientId,
        doctorId: doctorId,
        appointmentId: appointmentId,
        prescriptionId: prescriptionId,
        type: type,
        title: title,
        imageFile: imageFile,
        recordDate: recordDate,
        notes: notes,
      );
      return Right(record);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicalRecord({
    required String recordId,
    required String storagePath,
  }) async {
    try {
      await _remoteDataSource.deleteMedicalRecord(
        recordId: recordId,
        storagePath: storagePath,
      );
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
