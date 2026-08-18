import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
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

  DoctorDashboardRepositoryImpl(
    this._remoteDataSource,
    this._getAppointmentsUseCase,
    this._subscribeAppointmentsUseCase,
    this._callPatientUseCase,
    this._sortQueueUseCase,
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
  }) {
    final todayAppts = allAppts.where((a) {
      return a.doctorId == doctorId &&
          a.clinicId == clinicId &&
          a.date == todayStr;
    }).toList();

    final todayAppointmentsCount = todayAppts
        .where((a) => a.status != AppointmentStatus.cancelled)
        .length;

    final completedCount =
        todayAppts.where((a) => a.status == AppointmentStatus.done).length;

    final waitingCount = todayAppts.where((a) {
      return a.arrivedAt != null && a.status == AppointmentStatus.confirmed;
    }).length;

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

    final currentRaw = todayAppts
        .where((a) => a.status == AppointmentStatus.inProgress)
        .toList();
    final AppointmentEntity? currentPatient =
        currentRaw.isNotEmpty ? currentRaw.first : null;

    final todayWaitingAppts = allAppts.where((a) {
      return a.doctorId == doctorId &&
          a.clinicId == clinicId &&
          a.date == todayStr &&
          a.arrivedAt != null &&
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.inProgress &&
          a.status != AppointmentStatus.done;
    }).toList();

    final sortedAppts = _sortQueueUseCase(
      appointments: todayWaitingAppts,
    );

    final waitingQueue = sortedAppts
        .where((a) => a.status == AppointmentStatus.confirmed)
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
