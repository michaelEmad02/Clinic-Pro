// ────────────────────────────────────────────────────────
// تنفيذ مستودع المواعيد (AppointmentRepositoryImpl)
// يتعامل مع IAppointmentRemoteDataSource ويقوم بتحويل البيانات إلى كيانات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/i_appointment_repository.dart';
import '../data_sources/i_appointment_remote_data_source.dart';
import '../models/appointment_model.dart';

@LazySingleton(as: IAppointmentRepository)
class AppointmentRepositoryImpl implements IAppointmentRepository {
  final IAppointmentRemoteDataSource _remoteDataSource;

  AppointmentRepositoryImpl(this._remoteDataSource);

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
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(
      String id) async {
    try {
      final model = await _remoteDataSource.getAppointmentById(id);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> confirmArrival(String appointmentId) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {
          'status': AppointmentStatus.confirmed,
          'arrived_at': DateTime.now().toIso8601String(),
        },
      );
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
        date: targetAppt.date,
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
          'called_at': DateTime.now().toIso8601String(),
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAppointment(String appointmentId) async {
    try {
      await _remoteDataSource.updateFields(
        appointmentId: appointmentId,
        fields: {
          'status': AppointmentStatus.cancelled,
        },
      );

      // حذف الفواتير المرتبطة بالموعد عند إلغائه
      await _remoteDataSource.deleteRelatedInvoices(appointmentId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAppointment(String appointmentId) async {
    try {
      await _remoteDataSource.deleteAppointment(appointmentId);
      await _remoteDataSource.deleteRelatedInvoices(appointmentId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // كاش محلي للتحديثات الفورية بدون إعادة جلب كامل للقائمة من الشبكة
  List<AppointmentEntity> _cachedAppointments = [];

  @override
  Stream<List<AppointmentEntity>> subscribeAppointments({
    required String clinicId,
    String? doctorId,
  }) {
    return _remoteDataSource
        .subscribeAppointments(clinicId: clinicId)
        .asyncMap((rawList) async {
      // 1. تصفية الـ rawList بحسب doctorId إن وُجد
      final filteredRaw = doctorId != null && doctorId.isNotEmpty
          ? rawList.where((r) => r['doctor_id'] == doctorId).toList()
          : rawList;

      final rawIds = filteredRaw.map((r) => r['id'] as String).toSet();
      final cachedIds = _cachedAppointments.map((e) => e.id).toSet();

      // ─── الحالة 1: تحميل أول مرة ─── //
      if (_cachedAppointments.isEmpty) {
        try {
          final fresh = await _remoteDataSource.getAppointments(
            clinicId: clinicId,
            doctorId: doctorId,
          );
          _cachedAppointments = fresh;
          return fresh;
        } catch (_) {
          return <AppointmentEntity>[];
        }
      }

      // ─── الحالة 2: عنصر محذوف (DELETE) ─── //
      final deletedIds = cachedIds.difference(rawIds);
      if (deletedIds.isNotEmpty) {
        _cachedAppointments.removeWhere((item) => deletedIds.contains(item.id));
      }

      // ─── الحالة 3: عنصر مضاف جديد (INSERT) ─── //
      final addedIds = rawIds.difference(cachedIds);
      if (addedIds.isNotEmpty) {
        for (final newId in addedIds) {
          try {
            // نمر لإجابة موعد واحد فقط مثرى بدلاً من إعادة تحميل القائمة الكاملة!
            final newAppt = await _remoteDataSource.getEnrichedAppointmentById(newId);
            _cachedAppointments.add(newAppt);
          } catch (_) {}
        }
      }

      // ─── الحالة 4: تحديث موعد (UPDATE) ─── //
      final rawMap = {for (final r in filteredRaw) r['id'] as String: r};
      final updatedList = <AppointmentEntity>[];

      for (final cached in _cachedAppointments) {
        final raw = rawMap[cached.id];
        if (raw != null) {
          updatedList.add(cached.copyWith(
            status: raw['status'] as String? ?? cached.status,
            isUrgent: raw['is_urgent'] as bool? ?? cached.isUrgent,
            arrivedAt: raw['arrived_at'] != null
                ? DateTime.tryParse(raw['arrived_at'].toString())
                : cached.arrivedAt,
            calledAt: raw['called_at'] != null
                ? DateTime.tryParse(raw['called_at'].toString())
                : cached.calledAt,
            // notes: raw['notes'] as String? ?? cached.notes,
            // price: (raw['price'] as num?)?.toDouble() ?? cached.price,
          ));
        } else {
          updatedList.add(cached);
        }
      }

      _cachedAppointments = updatedList;
      return List<AppointmentEntity>.from(_cachedAppointments);
    });
  }
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}
