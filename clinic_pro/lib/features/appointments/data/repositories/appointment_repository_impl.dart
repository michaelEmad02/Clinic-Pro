// ────────────────────────────────────────────────────────
// تنفيذ مستودع المواعيد (AppointmentRepositoryImpl)
// يتعامل مع IAppointmentRemoteDataSource ويقوم بتحويل البيانات إلى كيانات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../data_sources/i_appointment_remote_data_source.dart';
import '../models/appointment_model.dart';

@LazySingleton(as: IAppointmentRepository)
class AppointmentRepositoryImpl implements IAppointmentRepository {
  final IAppointmentRemoteDataSource _remoteDataSource;

  // كاش محلي آمن للتحديثات الفورية بدون إعادة جلب كامل للقائمة من الشبكة
  List<AppointmentEntity> _cachedAppointments = const [];

  AppointmentRepositoryImpl(this._remoteDataSource);

  void _clearCache() {
    _cachedAppointments = const [];
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  }) async {
    try {
      final models = await _remoteDataSource.getAppointments(
        clinicId: clinicId,
        doctorId: doctorId,
        date: date,
        status: status,
      );
      return Right(models);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(
      String id) async {
    try {
      final model = await _remoteDataSource.getAppointmentById(id);
      return Right(model);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> addAppointment(
      AppointmentEntity appointment) async {
    try {
      final model = AppointmentModel(
        id: appointment.id,
        clinicId: appointment.clinicId,
        doctorId: appointment.doctorId,
        patientId: appointment.patientId,
        typeId: appointment.typeId,
        date: appointment.date,
        time: appointment.time,
        status: appointment.status,
        price: appointment.price,
        notes: appointment.notes,
        isUrgent: appointment.isUrgent,
        arrivedAt: appointment.arrivedAt,
        calledAt: appointment.calledAt,
        createdBy: appointment.createdBy,
        createdAt: appointment.createdAt,
      );

      final result = await _remoteDataSource.insertAppointment(model);
      _clearCache();
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmArrival(String appointmentId) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {
          'status': AppointmentStatus.confirmed,
          'arrived_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> callPatient(String appointmentId) async {
    try {
      final targetAppt =
          await _remoteDataSource.getAppointmentById(appointmentId);

      // البحث عن أي حالة قيد الفحص حالياً عند هذا الطبيب لإنهاء زيارته
      final activeInProg = await _remoteDataSource.getAppointments(
        clinicId: targetAppt.clinicId,
        doctorId: targetAppt.doctorId,
        status: AppointmentStatus.inProgress,
      );

      for (final appt in activeInProg) {
        await _remoteDataSource.updateFields(
          appointmentId: appt.id,
          fields: {
            'status': AppointmentStatus.done,
          },
        );
      }

      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {
          'status': AppointmentStatus.inProgress,
          'called_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStatus({
    required String appointmentId,
    required String newStatus,
  }) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {'status': newStatus},
      );
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAppointment(String appointmentId) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {'status': AppointmentStatus.cancelled},
      );
      try {
        await _remoteDataSource.deleteRelatedInvoices(appointmentId);
      } catch (_) {}
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleUrgent({
    required String appointmentId,
    required bool isUrgent,
  }) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {'is_urgent': isUrgent},
      );
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAppointment(
      AppointmentEntity appointment) async {
    try {
      final model = AppointmentModel(
        id: appointment.id,
        clinicId: appointment.clinicId,
        doctorId: appointment.doctorId,
        patientId: appointment.patientId,
        typeId: appointment.typeId,
        date: appointment.date,
        time: appointment.time,
        status: appointment.status,
        price: appointment.price,
        notes: appointment.notes,
        isUrgent: appointment.isUrgent,
        arrivedAt: appointment.arrivedAt,
        calledAt: appointment.calledAt,
        createdBy: appointment.createdBy,
        createdAt: appointment.createdAt,
      );

      await _remoteDataSource.updateAppointment(model);
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAppointment(String appointmentId) async {
    try {
      try {
        await _remoteDataSource.deleteRelatedInvoices(appointmentId);
      } catch (_) {}
      await _remoteDataSource.deleteAppointment(appointmentId);
      _clearCache();
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Stream<List<AppointmentEntity>> subscribeAppointments({
    required String clinicId,
    String? doctorId,
  }) {
    return _remoteDataSource
        .subscribeAppointments(clinicId: clinicId)
        .asyncMap((rawList) async {
      try {
        final fresh = await _remoteDataSource.getAppointments(
          clinicId: clinicId,
          doctorId: doctorId,
        );
        _cachedAppointments = List.unmodifiable(fresh);
        return _cachedAppointments;
      } catch (_) {
        return _cachedAppointments;
      }
    });
  }
}
