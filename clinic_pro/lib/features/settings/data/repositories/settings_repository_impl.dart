// ────────────────────────────────────────────────────────
// تنفيذ مستودع الإعدادات (SettingsRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:clinic_pro/core/error/storage_failure.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../domain/entities/queue_rule_entity.dart';
import '../../domain/entities/doctor_schedule_entity.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';
import '../data_sources/settings_remote_data_source.dart';
import '../models/doctor_schedule_model.dart';
import '../models/doctor_appointment_type_model.dart';

@LazySingleton(as: ISettingsRepository)
class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Unit>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? specialty,
    String? imageUrl,
  }) async {
    try {
      await _remoteDataSource.updateProfile(
        userId: userId,
        name: name,
        phone: phone,
        address: address,
        specialty: specialty,
        imageUrl: imageUrl,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
  }) async {
    try {
      final url = await _remoteDataSource.uploadAvatar(
        userId: userId,
        fileBytes: fileBytes,
      );
      return Right(url);
    } catch (e) {
      return Left(StorageFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ClinicEntity>> getClinicInfo(String clinicId) async {
    try {
      final clinic = await _remoteDataSource.getClinicInfo(clinicId);
      return Right(clinic);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClinicEntity>>> getAvailableClinics(
      String userId) async {
    try {
      final clinics = await _remoteDataSource.getAvailableClinics(userId);
      return Right(clinics);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateClinicInfo({
    required String clinicId,
    required String name,
    required String address,
    required String phone1,
    String? phone2,
    String? logoUrl,
  }) async {
    try {
      await _remoteDataSource.updateClinicInfo(
        clinicId: clinicId,
        name: name,
        address: address,
        phone1: phone1,
        phone2: phone2,
        logoUrl: logoUrl,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getSubscription(
      String ownerId) async {
    try {
      final subscription = await _remoteDataSource.getSubscription(ownerId);
      return Right(subscription);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  // ──── الطبيب (Doctor) فقط ────

  @override
  Future<Either<Failure, QueueRuleEntity?>> getQueueRule({
    required String doctorId,
    required String clinicId,
  }) async {
    try {
      final rule = await _remoteDataSource.getQueueRule(
        doctorId: doctorId,
        clinicId: clinicId,
      );
      return Right(rule);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertQueueRule({
    required String doctorId,
    required String clinicId,
    required String queueSystem,
    required List<String> slots,
    required int cycleLength,
    int? avgVisitMinutes,
  }) async {
    try {
      await _remoteDataSource.upsertQueueRule(
        doctorId: doctorId,
        clinicId: clinicId,
        queueSystem: queueSystem,
        slots: slots,
        cycleLength: cycleLength,
        avgVisitMinutes: avgVisitMinutes,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<DoctorScheduleEntity>>> getDoctorSchedules({
    required String doctorId,
    required String clinicId,
  }) async {
    try {
      final schedules = await _remoteDataSource.getDoctorSchedules(
        doctorId: doctorId,
        clinicId: clinicId,
      );
      return Right(schedules);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertDoctorSchedule(
      List<DoctorScheduleEntity> schedule) async {
    try {
      final models = schedule
          .map((dS) => DoctorScheduleModel(
                id: dS.id,
                doctorId: dS.doctorId,
                clinicId: dS.clinicId,
                dayOfWeek: dS.dayOfWeek,
                startTime: dS.startTime,
                endTime: dS.endTime,
              ))
          .toList();
      await _remoteDataSource.upsertDoctorSchedule(models);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<DoctorAppointmentTypeEntity>>>
      getDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
  }) async {
    try {
      final types = await _remoteDataSource.getDoctorAppointmentTypes(
        doctorId: doctorId,
        clinicId: clinicId,
      );
      return Right(types);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getGlobalAppointmentTypes() async {
    try {
      final types = await _remoteDataSource.getGlobalAppointmentTypes();
      return Right(types);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertDoctorAppointmentType(
      DoctorAppointmentTypeEntity typePrice) async {
    try {
      final model = DoctorAppointmentTypeModel(
        id: typePrice.id,
        doctorId: typePrice.doctorId,
        clinicId: typePrice.clinicId,
        appointmentTypeId: typePrice.appointmentTypeId,
        name: typePrice.name,
        price: typePrice.price,
      );
      await _remoteDataSource.upsertDoctorAppointmentType(model);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
    required List<DoctorAppointmentTypeEntity> types,
  }) async {
    try {
      final models = types
          .map((t) => DoctorAppointmentTypeModel(
                id: t.id,
                doctorId: t.doctorId,
                clinicId: t.clinicId,
                appointmentTypeId: t.appointmentTypeId,
                name: t.name,
                price: t.price,
              ))
          .toList();
      await _remoteDataSource.syncDoctorAppointmentTypes(
        doctorId: doctorId,
        clinicId: clinicId,
        types: models,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  // ──── السكرتير (Secretary) فقط ────

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSecretaryDoctors({
    required String secretaryId,
    required String clinicId,
  }) async {
    try {
      final doctors = await _remoteDataSource.getSecretaryDoctors(
        secretaryId: secretaryId,
        clinicId: clinicId,
      );
      return Right(doctors);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> setSecretaryActiveDoctor({
    required String secretaryId,
    required String clinicId,
    required String doctorId,
  }) async {
    try {
      await _remoteDataSource.setSecretaryActiveDoctor(
        secretaryId: secretaryId,
        clinicId: clinicId,
        doctorId: doctorId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
