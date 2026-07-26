// ─────────────────────────────────────────
// هذا الملف مسؤول عن إدارة حالة لوحة تحكم السكرتير
// يقوم بجلب البيانات الحية والمحاكاة لليوم الحالي من مستودع المواعيد والفواتير
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/appointments/get_appointments_usecase.dart';
import '../../../appointments/domain/usecases/appointments/confirm_arrival_usecase.dart';
import '../../../appointments/domain/usecases/appointments/call_patient_usecase.dart';
import 'secretary_dashboard_state.dart';

@injectable
class SecretaryDashboardCubit extends Cubit<SecretaryDashboardState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final ConfirmArrivalUseCase _confirmArrivalUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final ICloudService _cloudService;

  // معرفات السكرتير والعيادة النشطين
  String _secretaryId = '';
  String _clinicId = '';

  SecretaryDashboardCubit(
    this._getAppointmentsUseCase,
    this._confirmArrivalUseCase,
    this._callPatientUseCase,
    this._cloudService,
  ) : super(SecretaryDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم
  Future<void> loadDashboardData({
    required String secretaryId,
    required String clinicId,
  }) async {
    _secretaryId = secretaryId;
    _clinicId = clinicId;
    emit(SecretaryDashboardLoading());
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. جلب اسم السكرتير الحالي
      final secResults = await _cloudService.select(
        table: 'users',
        eq: {'id': _secretaryId},
      );
      final secretaryName = secResults.isNotEmpty
          ? secResults.first['name'] as String
          : 'أ. مريم العتيبي';

      // 2. تحميل الفواتير لحساب المبالغ المفوترة والمحصلة لليوم
      final invoices = await _cloudService.select(
        table: 'invoices',
        eq: {'clinic_id': _clinicId},
      );
      
      double invoicedSum = 0;
      double collectedSum = 0;

      for (final inv in invoices) {
        final createdAt = inv['created_at'] as String? ?? '';
        if (createdAt.startsWith(todayStr)) {
          invoicedSum += (inv['total_amount'] as num? ?? 0).toDouble();
          collectedSum += (inv['paid_amount'] as num? ?? 0).toDouble();
        }
      }

      // 3. تحميل المواعيد لليوم
      final appointmentsResult = await _getAppointmentsUseCase(
        GetAppointmentsParams(clinicId: _clinicId),
      );

      await appointmentsResult.fold(
        (failure) async => emit(SecretaryDashboardError(failure.message)),
        (allAppts) async {
          final todayAppts = allAppts.where((a) {
            return a.date == todayStr && a.clinicId == _clinicId;
          }).toList();

          // 4. جلب قائمة الانتظار الحالية (التي وصلت ولم تنتهِ ولم تُلغَ)
          final queueRaw = todayAppts.where((a) {
            return a.arrivedAt != null &&
                a.status != 'cancelled' &&
                a.status != 'done';
          }).toList();

          // ترتيب قائمة الانتظار حسب تاريخ الوصول arrived_at تصاعدياً
          queueRaw.sort((a, b) {
            final aTime = a.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aTime.compareTo(bTime);
          });

          // جلب أسماء الأطباء
          final users = await _cloudService.select(table: 'users');
          final doctorNames = {
            for (final u in users)
              if (u['role'] == 'doctor') u['id'] as String: u['name'] as String
          };

          // جلب بيانات العيادة الحالية المحددة
          final clinicResults = await _cloudService.select(
            table: 'clinics',
            eq: {'id': AppConstants.activeClinicId},
          );
          final clinicName = clinicResults.isNotEmpty
              ? clinicResults.first['name'] as String
              : AppStrings.currentClinic;

          final doctorName = doctorNames.values.isNotEmpty
              ? doctorNames.values.first
              : 'د. ياسر مصطفى';

          final liveQueue = queueRaw;

          emit(SecretaryDashboardLoaded(
            secretaryName: secretaryName,
            clinicName: clinicName,
            doctorName: doctorName,
            liveQueue: liveQueue,
            totalInvoiced: _formatCurrency(invoicedSum),
            totalCollected: _formatCurrency(collectedSum),
            totalAppointmentsCount: todayAppts.length,
          ));
        },
      );
    } catch (e) {
      emit(SecretaryDashboardError('${AppStrings.loadFailedMsg}: ${e.toString()}'));
    }
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

  String _formatCurrency(double amount) {
    if (amount == 0) return '0';
    final str = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return _toArabicNumbers(buffer.toString());
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
