import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_queue_rule_usecase.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/appointments/call_patient_usecase.dart';
import '../../../appointments/domain/usecases/appointments/get_appointments_usecase.dart';
import '../../../appointments/domain/usecases/appointments/sort_queue_usecase.dart';
import '../../../appointments/domain/usecases/appointments/subscribe_appointments_usecase.dart';
import '../../domain/entities/doctor_dashboard_data_entity.dart';
import '../../domain/repositories/i_doctor_dashboard_repository.dart';
import '../datasources/i_doctor_dashboard_remote_data_source.dart';

@LazySingleton(as: IDoctorDashboardRepository)
class DoctorDashboardRepositoryImpl implements IDoctorDashboardRepository {
  final IDoctorDashboardRemoteDataSource _remoteDataSource;
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final SubscribeAppointmentsUseCase _subscribeAppointmentsUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final SortQueueUseCase _sortQueueUseCase;
  final GetQueueRuleUseCase _getQueueRuleUseCase;

  DoctorDashboardRepositoryImpl(
    this._remoteDataSource,
    this._getAppointmentsUseCase,
    this._subscribeAppointmentsUseCase,
    this._callPatientUseCase,
    this._sortQueueUseCase,
    this._getQueueRuleUseCase,
  );

  @override
  Future<Either<Failure, DoctorDashboardDataEntity>> getDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  }) async {
    try {
      final info = await _remoteDataSource.fetchDoctorDashboardData(
        doctorId: doctorId,
        clinicId: clinicId,
        doctorName: doctorName,
        clinicName: clinicName,
      );
      final resolvedDoctorName = info['doctor_name'] as String;
      final resolvedClinicName = info['clinic_name'] as String;

      final ruleResult = await _getQueueRuleUseCase(
        doctorId: doctorId,
        clinicId: clinicId,
      );
      final queueRule = ruleResult.fold((_) => null, (rule) => rule);

      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final appointmentsResult = await _getAppointmentsUseCase(
        GetAppointmentsParams(clinicId: clinicId),
      );

      return appointmentsResult.fold(
        (failure) => Left(failure),
        (allAppts) {
          final data = _processAppointmentsToEntity(
            doctorName: resolvedDoctorName,
            clinicName: resolvedClinicName,
            doctorId: doctorId,
            clinicId: clinicId,
            allAppts: allAppts,
            todayStr: todayStr,
            queueRule: queueRule,
          );
          return Right(data);
        },
      );
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Stream<Either<Failure, DoctorDashboardDataEntity>> watchDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  }) async* {
    try {
      final info = await _remoteDataSource.fetchDoctorDashboardData(
        doctorId: doctorId,
        clinicId: clinicId,
        doctorName: doctorName,
        clinicName: clinicName,
      );
      final resolvedDoctorName = info['doctor_name'] as String;
      final resolvedClinicName = info['clinic_name'] as String;

      final ruleResult = await _getQueueRuleUseCase(
        doctorId: doctorId,
        clinicId: clinicId,
      );
      final queueRule = ruleResult.fold((_) => null, (rule) => rule);

      final stream = _subscribeAppointmentsUseCase(
        clinicId: clinicId,
        doctorId: doctorId,
      );

      await for (final allAppts in stream) {
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final data = _processAppointmentsToEntity(
          doctorName: resolvedDoctorName,
          clinicName: resolvedClinicName,
          doctorId: doctorId,
          clinicId: clinicId,
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

  DoctorDashboardDataEntity _processAppointmentsToEntity({
    required String doctorName,
    required String clinicName,
    required String doctorId,
    required String clinicId,
    required List<AppointmentEntity> allAppts,
    required String todayStr,
    QueueRuleEntity? queueRule,
  }) {
    final now = DateTime.now();

    // 1. All appointments for this doctor & clinic
    final doctorClinicAppts = allAppts.where((a) {
      return a.doctorId == doctorId && a.clinicId == clinicId;
    }).toList();

    // 2. Today's appointments (booked for today)
    final todayAppts = doctorClinicAppts.where((a) => a.date == todayStr).toList();

    final todayAppointmentsCount = todayAppts
        .where((a) => a.status != AppointmentStatus.cancelled)
        .length;

    final completedCount =
        todayAppts.where((a) => a.status == AppointmentStatus.done).length;

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

    // 3. Active queue candidates (arrived within last 24h or booked for today, and not cancelled)
    final activeQueueCandidates = doctorClinicAppts.where((a) {
      if (a.status == AppointmentStatus.cancelled) return false;

      final isToday = a.date == todayStr;
      final isArrivedRecently = a.arrivedAt != null &&
          now.difference(a.arrivedAt!.toLocal()).inHours.abs() < 24;

      return isToday || isArrivedRecently;
    }).toList();

    // 4. Current patient in progress
    final inProgressList = activeQueueCandidates
        .where((a) => a.status == AppointmentStatus.inProgress)
        .toList();
    final AppointmentEntity? currentPatient =
        inProgressList.isNotEmpty ? inProgressList.first : null;

    // 5. Waiting Count (confirmed patients sitting in waiting room)
    final waitingCount = activeQueueCandidates
        .where((a) => a.status == AppointmentStatus.confirmed && a.arrivedAt != null)
        .length;

    // 6. Sort all active candidates using QueueSorter (which splits fixed vs waiting)
    final sortedAppts = _sortQueueUseCase(
      appointments: activeQueueCandidates,
      rule: queueRule,
    );

    // 7. Filter waitingQueue (only confirmed waiting patients)
    final waitingQueue = sortedAppts
        .where((a) => a.status == AppointmentStatus.confirmed && a.arrivedAt != null)
        .toList();

    return DoctorDashboardDataEntity(
      doctorName: doctorName,
      clinicName: clinicName,
      currentPatient: currentPatient,
      waitingQueue: waitingQueue,
      todayAppointmentsCount: todayAppointmentsCount,
      completedCount: completedCount,
      waitingCount: waitingCount,
      avgWaitingTime: avgWaitingTime,
    );
  }

  @override
  Future<Either<Failure, void>> callNextPatient({
    required String appointmentId,
  }) async {
    try {
      final result = await _callPatientUseCase(appointmentId);
      return result;
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
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
