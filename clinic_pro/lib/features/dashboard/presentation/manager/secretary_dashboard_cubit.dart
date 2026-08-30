import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../../appointments/domain/usecases/appointments/confirm_arrival_usecase.dart';
import '../../../appointments/domain/usecases/appointments/call_patient_usecase.dart';
import '../../domain/usecases/get_secretary_dashboard_data_usecase.dart';
import '../../domain/usecases/watch_secretary_dashboard_data_usecase.dart';
import 'secretary_dashboard_state.dart';

@injectable
class SecretaryDashboardCubit extends Cubit<SecretaryDashboardState> {
  final GetSecretaryDashboardDataUseCase _getSecretaryDashboardDataUseCase;
  final WatchSecretaryDashboardDataUseCase _watchSecretaryDashboardDataUseCase;
  final ConfirmArrivalUseCase _confirmArrivalUseCase;
  final CallPatientUseCase _callPatientUseCase;

  StreamSubscription? _dashboardSubscription;
  String _secretaryId = '';
  String _clinicId = '';

  SecretaryDashboardCubit(
    this._getSecretaryDashboardDataUseCase,
    this._watchSecretaryDashboardDataUseCase,
    this._confirmArrivalUseCase,
    this._callPatientUseCase,
  ) : super(SecretaryDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم مع الاشتراك اللحظي
  Future<void> loadDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
    bool showLoading = false,
  }) async {
    _secretaryId = secretaryId;
    _clinicId = clinicId;

    if (state is SecretaryDashboardInitial || showLoading) {
      emit(SecretaryDashboardLoading());
    }

    await _dashboardSubscription?.cancel();

    final params = GetSecretaryDashboardDataParams(
      secretaryId: _secretaryId,
      clinicId: _clinicId,
      secretaryName: secretaryName,
      clinicName: clinicName,
    );

    try {
      final initialResult = await _getSecretaryDashboardDataUseCase(params);

      initialResult.fold(
        (failure) {
          if (state is! SecretaryDashboardLoaded) {
            emit(SecretaryDashboardError(failure.message));
          }
        },
        (data) {
          emit(SecretaryDashboardLoaded(
            secretaryName: data.secretaryName,
            clinicName: data.clinicName,
            doctorName: data.doctorName,
            liveQueue: data.liveQueue,
            todayAppointmentsCount: data.todayAppointmentsCount,
            completedCount: data.completedCount,
            waitingCount: data.waitingCount,
            avgWaitingTime: data.avgWaitingTime,
          ));
        },
      );
    } catch (e) {
      if (state is! SecretaryDashboardLoaded) {
        emit(SecretaryDashboardError(e.toString()));
      }
    }

    _dashboardSubscription = _watchSecretaryDashboardDataUseCase(params).listen(
      (result) {
        result.fold(
          (failure) {},
          (data) {
            emit(SecretaryDashboardLoaded(
              secretaryName: data.secretaryName,
              clinicName: data.clinicName,
              doctorName: data.doctorName,
              liveQueue: data.liveQueue,
              todayAppointmentsCount: data.todayAppointmentsCount,
              completedCount: data.completedCount,
              waitingCount: data.waitingCount,
              avgWaitingTime: data.avgWaitingTime,
            ));
          },
        );
      },
      onError: (_) {},
    );
  }

  /// تأكيد وصول المريض
  Future<void> confirmArrival(String appointmentId) async {
    try {
      final result = await _confirmArrivalUseCase(appointmentId);
      await result.fold(
        (failure) async => emit(SecretaryDashboardError(failure.message)),
        (_) => loadDashboardData(secretaryId: _secretaryId, clinicId: _clinicId),
      );
    } catch (_) {
      emit(SecretaryDashboardError(AppStrings.isArabic ? 'تعذّر تأكيد وصول المريض' : 'Failed to confirm patient arrival'));
    }
  }

  /// استدعاء المريض
  Future<void> callPatient(String appointmentId) async {
    try {
      final result = await _callPatientUseCase(appointmentId);
      await result.fold(
        (failure) async => emit(SecretaryDashboardError(failure.message)),
        (_) => loadDashboardData(secretaryId: _secretaryId, clinicId: _clinicId),
      );
    } catch (_) {
      emit(SecretaryDashboardError(AppStrings.isArabic ? 'تعذّر استدعاء المريض' : 'Failed to call patient'));
    }
  }

  @override
  Future<void> close() {
    _dashboardSubscription?.cancel();
    return super.close();
  }
}
