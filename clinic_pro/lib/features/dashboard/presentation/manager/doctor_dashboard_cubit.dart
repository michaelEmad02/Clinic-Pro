// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة حالة لوحة تحكم الطبيب (DoctorDashboardCubit)
// يقوم بجلب البيانات الحية والمحاكاة لليوم الحالي من مستودع المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/appointments/get_appointments_usecase.dart';
import '../../../appointments/domain/usecases/appointments/call_patient_usecase.dart';
import '../../../appointments/domain/usecases/appointments/sort_queue_usecase.dart';
import 'doctor_dashboard_state.dart';

@injectable
class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final SortQueueUseCase _sortQueueUseCase;
  final ICloudService _cloudService;

  // معرفات الطبيب والعيادة النشطين
  String _doctorId = '';
  String _clinicId = '';

  DoctorDashboardCubit(
    this._getAppointmentsUseCase,
    this._callPatientUseCase,
    this._sortQueueUseCase,
    this._cloudService,
  ) : super(DoctorDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم من خلال المستودع والخدمات السحابية
  Future<void> loadDashboardData({
    required String doctorId,
    required String clinicId,
    bool autoCallNext = false,
  }) async {
    _doctorId = doctorId;
    _clinicId = clinicId;
    emit(DoctorDashboardLoading());
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. جلب بيانات الطبيب الحالي لعرض الاسم
      final doctorResults = await _cloudService.select(
        table: 'users',
        eq: {'id': _doctorId},
      );
      final doctorName = doctorResults.isNotEmpty
          ? doctorResults.first['name'] as String
          : 'د. ياسر مصطفى';

      // جلب بيانات العيادة الحالية المحددة
      final clinicResults = await _cloudService.select(
        table: 'clinics',
        eq: {'id': _clinicId},
      );
      final clinicName = clinicResults.isNotEmpty
          ? clinicResults.first['name'] as String
          : 'عيادة كليوباترا لطب الأطفال';

      // 2. تحميل كافة المواعيد لحساب الإحصائيات (المفلترة بالعيادة النشطة)
      final appointmentsResult = await _getAppointmentsUseCase(
        GetAppointmentsParams(clinicId: _clinicId),
      );

      await appointmentsResult.fold(
        (failure) async => emit(DoctorDashboardError(failure.message)),
        (allAppts) async {
          final todayAppts = allAppts.where((a) {
            return a.doctorId == _doctorId &&
                a.clinicId == _clinicId &&
                a.date == todayStr;
          }).toList();

          // حساب عدد الحالات المكتملة لليوم
          final completedCount = todayAppts.where((a) => a.status == 'done').length;

          // حساب عدد الحالات المنتظرة لليوم (التي وصلت ولم يتم استدعاؤها بعد)
          final waitingCount = todayAppts.where((a) {
            return a.arrivedAt != null && a.status == 'confirmed';
          }).length;

          // 3. حساب متوسط وقت الانتظار بناءً على الحالات التي استدعيت بالفعل
          int totalMinutes = 0;
          int calledCount = 0;
          for (final appt in todayAppts) {
            if (appt.calledAt != null && appt.arrivedAt != null) {
              totalMinutes += appt.calledAt!.difference(appt.arrivedAt!).inMinutes;
              calledCount++;
            }
          }
          final avgMinutes = calledCount > 0 ? (totalMinutes / calledCount).round() : 0;
          final avgWaitingTime = avgMinutes > 0
              ? _toArabicNumbers('$avgMinutes ${AppStrings.isArabic ? 'دقيقة' : 'min'}')
              : '—';

          // 4. جلب المريض الحالي قيد الكشف إن وجد
          final currentRaw = todayAppts.where((a) => a.status == 'in_progress').toList();
          final AppointmentEntity? currentPatient =
              currentRaw.isNotEmpty ? currentRaw.first : null;

          // 5. جلب وترتيب طابور الانتظار
          final todayWaitingAppts = allAppts.where((a) {
            return a.doctorId == _doctorId &&
                a.clinicId == _clinicId &&
                a.date == todayStr &&
                a.arrivedAt != null &&
                a.status != 'cancelled' &&
                a.status != 'done';
          }).toList();

          // ترتيب الطابور
          final sortedAppts = _sortQueueUseCase(
            appointments: todayWaitingAppts,
          );

          final waitingQueue = sortedAppts
              .where((a) => a.status == 'confirmed')
              .toList();

          // إذا تطلب الأمر استدعاء تلقائي للمريض التالي وكان المريض الحالي فارغاً والطابور غير فارغ
          if (autoCallNext && currentPatient == null && waitingQueue.isNotEmpty) {
            final nextPatient = waitingQueue.first;
            await _callPatientUseCase(nextPatient.id);
            await loadDashboardData(doctorId: _doctorId, clinicId: _clinicId);
            return;
          }

          emit(DoctorDashboardLoaded(
            doctorName: doctorName,
            clinicName: clinicName,
            currentPatient: currentPatient,
            waitingQueue: waitingQueue,
            completedCount: completedCount,
            waitingCount: waitingCount,
            avgWaitingTime: avgWaitingTime,
          ));
        },
      );
    } catch (e) {
      emit(DoctorDashboardError('${AppStrings.loadFailedMsg}: ${e.toString()}'));
    }
  }

  /// استدعاء المريض التالي في الطابور
  Future<void> callNextPatient() async {
    if (state is! DoctorDashboardLoaded) return;
    final loaded = state as DoctorDashboardLoaded;

    if (loaded.waitingQueue.isNotEmpty) {
      final nextPatient = loaded.waitingQueue.first;
      try {
        await _callPatientUseCase(nextPatient.id);
        await loadDashboardData(doctorId: _doctorId, clinicId: _clinicId);
      } catch (_) {
        emit(const DoctorDashboardError('تعذّر استدعاء المريض التالي'));
      }
    }
  }

  /// تحويل الأرقام الإنجليزية إلى أرقام عربية للتنسيق اللغوي
  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
