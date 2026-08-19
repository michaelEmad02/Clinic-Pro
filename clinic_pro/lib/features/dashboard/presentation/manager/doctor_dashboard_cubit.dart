// ────────────────────────────────────────────────────────
// إدارة حالة لوحة تحكم الطبيب (DoctorDashboardCubit)
// تدعم الاشتراك اللحظي الفوري (Realtime Stream) والتأثير المباشر
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import '../../../appointments/domain/usecases/appointments/call_patient_usecase.dart';
import '../../../appointments/domain/usecases/appointments/cancel_appointment_usecase.dart';
import '../../../appointments/domain/usecases/appointments/update_appointment_status_usecase.dart';
import '../../domain/usecases/get_doctor_dashboard_data_usecase.dart';
import '../../domain/usecases/watch_doctor_dashboard_data_usecase.dart';
import 'doctor_dashboard_state.dart';

@injectable
class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  final GetDoctorDashboardDataUseCase _getDoctorDashboardDataUseCase;
  final WatchDoctorDashboardDataUseCase _watchDoctorDashboardDataUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final UpdateAppointmentStatusUseCase _updateAppointmentStatusUseCase;
  final CancelAppointmentUseCase _cancelAppointmentUseCase;

  StreamSubscription? _dashboardSubscription;
  String _doctorId = '';
  String _clinicId = '';

  DoctorDashboardCubit(
    this._getDoctorDashboardDataUseCase,
    this._watchDoctorDashboardDataUseCase,
    this._callPatientUseCase,
    this._updateAppointmentStatusUseCase,
    this._cancelAppointmentUseCase,
  ) : super(DoctorDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم مع الاشتراك اللحظي
  Future<void> loadDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
    bool autoCallNext = false,
  }) async {
    _doctorId = doctorId;
    _clinicId = clinicId;
    emit(DoctorDashboardLoading());

    // إلغاء أي اشتراك سابق إن وجد
    await _dashboardSubscription?.cancel();

    final params = GetDoctorDashboardDataParams(
      doctorId: _doctorId,
      clinicId: _clinicId,
      doctorName: doctorName,
      clinicName: clinicName,
    );

    // 1. جلب البيانات الأوّلية فوراً
    final initialResult = await _getDoctorDashboardDataUseCase(params);

    initialResult.fold(
      (failure) => emit(DoctorDashboardError(failure.message)),
      (data) {
        emit(DoctorDashboardLoaded(
          doctorName: data.doctorName,
          clinicName: data.clinicName,
          currentPatient: data.currentPatient,
          waitingQueue: data.waitingQueue,
          todayAppointmentsCount: data.todayAppointmentsCount,
          completedCount: data.completedCount,
          waitingCount: data.waitingCount,
          avgWaitingTime: data.avgWaitingTime,
        ));
      },
    );

    // 2. البدء بالاستماع المباشر الفوري للتغييرات اللحظية (Real-time Stream)
    _dashboardSubscription = _watchDoctorDashboardDataUseCase(params).listen((result) async {
      result.fold(
        (failure) {},
        (data) async {
          if (autoCallNext &&
              data.currentPatient == null &&
              data.waitingQueue.isNotEmpty) {
            final nextPatient = data.waitingQueue.first;
            await _callPatientUseCase(nextPatient.id);
            return;
          }

          emit(DoctorDashboardLoaded(
            doctorName: data.doctorName,
            clinicName: data.clinicName,
            currentPatient: data.currentPatient,
            waitingQueue: data.waitingQueue,
            todayAppointmentsCount: data.todayAppointmentsCount,
            completedCount: data.completedCount,
            waitingCount: data.waitingCount,
            avgWaitingTime: data.avgWaitingTime,
          ));
        },
      );
    });
  }

  /// استدعاء المريض التالي في الطابور
  Future<void> callNextPatient() async {
    if (state is! DoctorDashboardLoaded) return;
    final loaded = state as DoctorDashboardLoaded;

    if (loaded.waitingQueue.isNotEmpty) {
      final nextPatient = loaded.waitingQueue.first;
      try {
        await _callPatientUseCase(nextPatient.id);
      } catch (_) {
        emit(DoctorDashboardError(
          AppStrings.isArabic ? 'تعذّر استدعاء المريض التالي' : 'Failed to call next patient',
        ));
      }
    }
  }

  /// إتمام كشف موعد معين (تحويل الحالة إلى done)
  Future<void> completeAppointment(String appointmentId) async {
    await _updateAppointmentStatusUseCase(
      appointmentId: appointmentId,
      newStatus: AppointmentStatus.done,
    );
  }

  /// إلغاء موعد معين (تحويل الحالة إلى cancelled)
  Future<void> cancelAppointment(String appointmentId) async {
    await _cancelAppointmentUseCase(appointmentId);
  }

  @override
  Future<void> close() {
    _dashboardSubscription?.cancel();
    return super.close();
  }
}
