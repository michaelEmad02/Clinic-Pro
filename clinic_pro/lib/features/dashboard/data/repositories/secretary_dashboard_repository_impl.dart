import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';
import 'package:clinic_pro/features/settings/data/data_sources/settings_remote_data_source.dart';
import 'package:clinic_pro/features/appointments/data/data_sources/i_appointment_remote_data_source.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/appointments/sort_queue_usecase.dart';
import '../../domain/entities/secretary_dashboard_data_entity.dart';
import '../../domain/repositories/i_secretary_dashboard_repository.dart';
import '../datasources/i_secretary_dashboard_remote_data_source.dart';

@LazySingleton(as: ISecretaryDashboardRepository)
class SecretaryDashboardRepositoryImpl implements ISecretaryDashboardRepository {
  final ISecretaryDashboardRemoteDataSource _remoteDataSource;
  final IAppointmentRemoteDataSource _appointmentRemoteDataSource;
  final ISettingsRemoteDataSource _settingsRemoteDataSource;
  final SortQueueUseCase _sortQueueUseCase;

  SecretaryDashboardRepositoryImpl(
    this._remoteDataSource,
    this._appointmentRemoteDataSource,
    this._settingsRemoteDataSource,
    this._sortQueueUseCase,
  );

  @override
  Future<Either<Failure, SecretaryDashboardDataEntity>> getSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  }) async {
    try {
      final info = await _remoteDataSource.fetchSecretaryDashboardData(
        secretaryId: secretaryId,
        clinicId: clinicId,
        secretaryName: secretaryName,
        clinicName: clinicName,
      );
      final resolvedSecretaryName = info['secretary_name'] as String;
      final resolvedClinicName = info['clinic_name'] as String;
      final doctorName = info['doctor_name'] as String;
      final activeDoctorId = info['active_doctor_id'] as String?;

      QueueRuleEntity? queueRule;
      if (activeDoctorId != null) {
        queueRule = await _settingsRemoteDataSource.getQueueRule(
          doctorId: activeDoctorId,
          clinicId: clinicId,
        );
      }

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final allAppts = await _appointmentRemoteDataSource.getAppointments(
        clinicId: clinicId,
      );

      final data = _processAppointmentsToEntity(
        secretaryName: resolvedSecretaryName,
        clinicName: resolvedClinicName,
        doctorName: doctorName,
        allAppts: allAppts,
        todayStr: todayStr,
        queueRule: queueRule,
      );
      return Right(data);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Stream<Either<Failure, SecretaryDashboardDataEntity>> watchSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  }) async* {
    try {
      final info = await _remoteDataSource.fetchSecretaryDashboardData(
        secretaryId: secretaryId,
        clinicId: clinicId,
        secretaryName: secretaryName,
        clinicName: clinicName,
      );
      final resolvedSecretaryName = info['secretary_name'] as String;
      final resolvedClinicName = info['clinic_name'] as String;
      final doctorName = info['doctor_name'] as String;
      final activeDoctorId = info['active_doctor_id'] as String?;

      QueueRuleEntity? queueRule;
      if (activeDoctorId != null) {
        queueRule = await _settingsRemoteDataSource.getQueueRule(
          doctorId: activeDoctorId,
          clinicId: clinicId,
        );
      }

      final stream = _appointmentRemoteDataSource
          .subscribeAppointments(clinicId: clinicId)
          .asyncMap((_) async {
        return await _appointmentRemoteDataSource.getAppointments(
          clinicId: clinicId,
        );
      });

      await for (final allAppts in stream) {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final data = _processAppointmentsToEntity(
          secretaryName: resolvedSecretaryName,
          clinicName: resolvedClinicName,
          doctorName: doctorName,
          allAppts: allAppts,
          todayStr: todayStr,
          queueRule: queueRule,
        );
        yield Right(data);
      }
    } catch (e) {
      yield Left(QueryFailure.fromException(e));
    }
  }

  SecretaryDashboardDataEntity _processAppointmentsToEntity({
    required String secretaryName,
    required String clinicName,
    required String doctorName,
    required List<AppointmentEntity> allAppts,
    required String todayStr,
    QueueRuleEntity? queueRule,
  }) {
    final now = DateTime.now();

    // 1. مواعيد اليوم للعيادة (المحجوزة لليوم وغير الملقاة)
    final todayAppts = allAppts.where((a) => a.date == todayStr).toList();

    final todayAppointmentsCount = todayAppts
        .where((a) => a.status != AppointmentStatus.cancelled)
        .length;

    final completedCount =
        todayAppts.where((a) => a.status == AppointmentStatus.done).length;

    // 2. حساب متوسط الانتظار
    int totalMinutes = 0;
    int calledCount = 0;
    for (final appt in todayAppts) {
      if (appt.calledAt != null && appt.arrivedAt != null) {
        totalMinutes += appt.calledAt!.difference(appt.arrivedAt!).inMinutes;
        calledCount++;
      }
    }
    final avgMinutes =
        calledCount > 0 ? (totalMinutes / calledCount).round() : 0;
    final avgWaitingTime = avgMinutes > 0
        ? _toArabicNumbers(
            '$avgMinutes ${AppStrings.isArabic ? 'دقيقة' : 'min'}')
        : '—';

    // 3. مرشحي قائمة الانتظار الحية (وصلوا خلال آخر 24 ساعة أو مواعيد اليوم وغير ملغاة)
    final activeQueueCandidates = allAppts.where((a) {
      if (a.status == AppointmentStatus.cancelled) return false;

      final isToday = a.date == todayStr;
      final isArrivedRecently = a.arrivedAt != null &&
          now.difference(a.arrivedAt!.toLocal()).inHours.abs() < 24;

      return isToday || isArrivedRecently;
    }).toList();

    // 4. عدد المنتظرين في العيادة (الذين وصلت حالتهم confirmed وتم تأكيد وصولهم ولم يخرجوا بعد)
    final waitingCount = activeQueueCandidates
        .where((a) => a.status == AppointmentStatus.confirmed && a.arrivedAt != null)
        .length;

    // 5. ترتيب قائمة الانتظار
    final sortedAppts = _sortQueueUseCase(
      appointments: activeQueueCandidates,
      rule: queueRule,
    );

    // 6. قائمة الانتظار الحية المفلترة للعرض (مرتبة بدون الملغاة أو المكتملة مسبقاً)
    final liveQueue = sortedAppts
        .where((a) => a.status != AppointmentStatus.cancelled && a.status != AppointmentStatus.done)
        .toList();

    return SecretaryDashboardDataEntity(
      secretaryName: secretaryName,
      clinicName: clinicName,
      doctorName: doctorName,
      liveQueue: liveQueue,
      todayAppointmentsCount: todayAppointmentsCount,
      completedCount: completedCount,
      waitingCount: waitingCount,
      avgWaitingTime: avgWaitingTime,
    );
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
