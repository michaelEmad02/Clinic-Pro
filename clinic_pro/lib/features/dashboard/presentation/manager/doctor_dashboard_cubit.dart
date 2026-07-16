// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة حالة لوحة تحكم الطبيب (DoctorDashboardCubit)
// يقوم بجلب البيانات الحية والمحاكاة لليوم الحالي من مستودع المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../appointments/presentation/manager/appointments_repository.dart';
import '../../../appointments/presentation/manager/appointments_state.dart';
import 'doctor_dashboard_state.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  final AppointmentsRepository _repository;
  final ICloudService _cloudService;

  // معرف الطبيب الافتراضي للمحاكاة
  static const String _currentDoctorId = 'u-doc-1';

  DoctorDashboardCubit(this._repository, this._cloudService) : super(DoctorDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم من خلال المستودع والخدمات السحابية
  Future<void> loadDashboardData({bool autoCallNext = false}) async {
    emit(DoctorDashboardLoading());
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. جلب بيانات الطبيب الحالي لعرض الاسم
      final doctorResults = await _cloudService.select(
        table: 'users',
        eq: {'id': _currentDoctorId},
      );
      final doctorName = doctorResults.isNotEmpty 
          ? doctorResults.first['name'] as String 
          : 'د. ياسر مصطفى';

      // جلب بيانات العيادة الحالية المحددة
      final clinicResults = await _cloudService.select(
        table: 'clinics',
        eq: {'id': AppConstants.activeClinicId},
      );
      final clinicName = clinicResults.isNotEmpty
          ? clinicResults.first['name'] as String
          : 'عيادة كليوباترا لطب الأطفال';

      // 2. تحميل كافة المواعيد لحساب الإحصائيات (المفلترة بالعيادة النشطة)
      final allAppts = await _repository.loadAppointments();
      final todayAppts = allAppts.where((a) {
        return a['doctor_id'] == _currentDoctorId && 
               a['clinic_id'] == AppConstants.activeClinicId &&
               a['date'] == todayStr;
      }).toList();

      // حساب عدد الحالات المكتملة لليوم
      final completedCount = todayAppts.where((a) => a['status'] == 'done').length;

      // حساب عدد الحالات المنتظرة لليوم (التي وصلت ولم يتم استدعاؤها بعد)
      final waitingCount = todayAppts.where((a) {
        return a['arrived_at'] != null && a['status'] == 'confirmed';
      }).length;

      // 3. حساب متوسط وقت الانتظار بناءً على الحالات التي استدعيت بالفعل
      int totalMinutes = 0;
      int calledCount = 0;
      for (final appt in todayAppts) {
        if (appt['called_at'] != null && appt['arrived_at'] != null) {
          final called = DateTime.parse(appt['called_at'] as String);
          final arrived = DateTime.parse(appt['arrived_at'] as String);
          totalMinutes += called.difference(arrived).inMinutes;
          calledCount++;
        }
      }
      final avgMinutes = calledCount > 0 ? (totalMinutes / calledCount).round() : 0;
      final avgWaitingTime = avgMinutes > 0 ? _toArabicNumbers('$avgMinutes ${AppStrings.isArabic ? 'دقيقة' : 'min'}') : '—';

      // 4. جلب المريض الحالي قيد الكشف إن وجد
      final currentRaw = todayAppts.where((a) => a['status'] == 'in_progress').toList();
      final AppointmentItem? currentPatient = currentRaw.isNotEmpty 
          ? _mapAppointments(currentRaw).first 
          : null;

      // 5. جلب وترتيب طابور الانتظار باستثناء المريض الحالي قيد الكشف
      final rawQueue = await _repository.loadQueue(_currentDoctorId, todayStr);
      final waitingQueue = _mapAppointments(rawQueue)
          .where((a) => a.status == 'confirmed')
          .toList();

      // إذا تطلب الأمر استدعاء تلقائي للمريض التالي وكان المريض الحالي فارغاً والطابور غير فارغ
      if (autoCallNext && currentPatient == null && waitingQueue.isNotEmpty) {
        final nextPatient = waitingQueue.first;
        await _repository.callPatient(nextPatient.id);
        // إعادة التحديث لعرض الحالة المحدثة للمريض الجديد
        await loadDashboardData();
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
        // تحديث حالة المريض في قاعدة البيانات واستدعاؤه
        await _repository.callPatient(nextPatient.id);
        // إعادة تحميل البيانات لتحديث الواجهة تلقائياً وبشكل متناسق
        await loadDashboardData();
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

  /// تنسيق الوقت للعرض (مثال: 16:30 -> 4:30 م)
  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return _toArabicNumbers('$displayHour:$minute $period');
  }

  /// تحويل القائمة الخام من المستودع إلى كائنات AppointmentItem المعيارية
  List<AppointmentItem> _mapAppointments(List<Map<String, dynamic>> rawList) {
    return rawList.map((raw) {
      final patient = raw['patients'] as Map<String, dynamic>? ?? {};
      final type = raw['appointment_types'] as Map<String, dynamic>? ?? {};
      final doctorId = raw['doctor_id'] as String;

      final prescriptions = raw['prescriptions'] as List<dynamic>? ?? [];
      final invoices = raw['invoices'] as List<dynamic>? ?? [];

      final apptId = raw['id'] as String;

      return AppointmentItem(
        id: apptId,
        patientId: raw['patient_id'] as String,
        patientName: patient['name'] as String? ?? AppStrings.patient,
        patientPhone: patient['phone'] as String? ?? '',
        doctorId: doctorId,
        doctorName: AppStrings.generalPractitioner,
        typeId: raw['appointment_type_id'] as String,
        typeName: type['name'] as String? ?? AppStrings.normalCheckup,
        date: raw['date'] as String,
        displayTime: _formatTime(raw['time'] as String? ?? '00:00:00'),
        rawTime: raw['time'] as String? ?? '00:00:00',
        status: raw['status'] as String,
        price: (raw['price'] as num).toDouble(),
        isUrgent: raw['is_urgent'] as bool? ?? false,
        notes: raw['notes'] as String?,
        arrivedAt: raw['arrived_at'] != null
            ? DateTime.parse(raw['arrived_at'] as String)
            : null,
        calledAt: raw['called_at'] != null
            ? DateTime.parse(raw['called_at'] as String)
            : null,
        hasPrescription: prescriptions.isNotEmpty,
        hasInvoice: invoices.isNotEmpty,
        prescriptionDiagnosis: prescriptions.isNotEmpty
            ? prescriptions.first['diagnosis'] as String?
            : null,
        invoiceAmount: invoices.isNotEmpty
            ? '${invoices.first['amount']}'
            : null,
        invoiceStatus: invoices.isNotEmpty
            ? invoices.first['status'] as String?
            : null,
        invoiceNumber: invoices.isNotEmpty
            ? '#INV-${apptId.length > 4 ? apptId.substring(apptId.length - 4) : apptId}'
            : null,
      );
    }).toList();
  }
}
