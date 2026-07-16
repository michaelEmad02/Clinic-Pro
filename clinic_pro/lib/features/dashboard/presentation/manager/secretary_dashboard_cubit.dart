// ─────────────────────────────────────────
// هذا الملف مسؤول عن إدارة حالة لوحة تحكم السكرتير
// يقوم بجلب البيانات الحية والمحاكاة لليوم الحالي من مستودع المواعيد والفواتير
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../appointments/presentation/manager/appointments_repository.dart';
import '../../../appointments/presentation/manager/appointments_state.dart';
import 'secretary_dashboard_state.dart';

@injectable
class SecretaryDashboardCubit extends Cubit<SecretaryDashboardState> {
  final AppointmentsRepository _appointmentsRepository;
  final ICloudService _cloudService;

  // معرف السكرتير الافتراضي للمحاكاة
  static const String _currentSecretaryId = 'u-sec-1';

  SecretaryDashboardCubit(
    this._appointmentsRepository,
    this._cloudService,
  ) : super(SecretaryDashboardInitial());

  /// تحميل كافة بيانات لوحة التحكم
  Future<void> loadDashboardData() async {
    emit(SecretaryDashboardLoading());
    try {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // 1. جلب اسم السكرتير الحالي
      final secResults = await _cloudService.select(
        table: 'users',
        eq: {'id': _currentSecretaryId},
      );
      final secretaryName = secResults.isNotEmpty
          ? secResults.first['name'] as String
          : 'أ. مريم العتيبي';

      // 2. تحميل الفواتير لحساب المبالغ المفوترة والمحصلة لليوم
      final invoices = await _cloudService.select(
        table: 'invoices',
        eq: {'clinic_id': AppConstants.activeClinicId},
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
      final allAppts = await _appointmentsRepository.loadAppointments();
      final todayAppts = allAppts.where((a) {
        return a['date'] == todayStr && a['clinic_id'] == AppConstants.activeClinicId;
      }).toList();

      // 4. جلب قائمة الانتظار الحالية (التي وصلت ولم تنتهِ ولم تُلغَ)
      final queueRaw = todayAppts.where((a) {
        return a['arrived_at'] != null &&
            a['status'] != 'cancelled' &&
            a['status'] != 'done';
      }).toList();

      // ترتيب قائمة الانتظار حسب تاريخ الوصول arrived_at تصاعدياً
      queueRaw.sort((a, b) {
        final aTime = a['arrived_at'] as String? ?? '';
        final bTime = b['arrived_at'] as String? ?? '';
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

      final liveQueue = _mapAppointments(queueRaw, doctorNames);

      emit(SecretaryDashboardLoaded(
        secretaryName: secretaryName,
        clinicName: clinicName,
        doctorName: doctorName,
        liveQueue: liveQueue,
        totalInvoiced: _formatCurrency(invoicedSum),
        totalCollected: _formatCurrency(collectedSum),
        totalAppointmentsCount: todayAppts.length,
      ));
    } catch (e) {
      emit(SecretaryDashboardError('${AppStrings.loadFailedMsg}: ${e.toString()}'));
    }
  }

  /// تأكيد وصول المريض
  Future<void> confirmArrival(String appointmentId) async {
    try {
      await _appointmentsRepository.confirmArrival(appointmentId);
      await loadDashboardData();
    } catch (_) {
      emit(SecretaryDashboardError(AppStrings.isArabic ? 'تعذّر تأكيد وصول المريض' : 'Failed to confirm patient arrival'));
    }
  }

  /// استدعاء المريض
  Future<void> callPatient(String appointmentId) async {
    try {
      await _appointmentsRepository.callPatient(appointmentId);
      await loadDashboardData();
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

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = AppStrings.isArabic ? (hour >= 12 ? 'م' : 'ص') : (hour >= 12 ? 'PM' : 'AM');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return _toArabicNumbers('$displayHour:$minute $period');
  }

  List<AppointmentItem> _mapAppointments(
    List<Map<String, dynamic>> rawList,
    Map<String, String> doctorNames,
  ) {
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
        doctorName: doctorNames[doctorId] ?? AppStrings.generalPractitioner,
        typeId: raw['appointment_type_id'] as String,
        typeName: type['name'] as String? ?? AppStrings.normalCheckup,
        date: raw['date'] as String,
        displayTime: _formatTime(raw['time'] as String? ?? '00:00:00'),
        rawTime: raw['time'] as String? ?? '00:00:00',
        status: raw['status'] as String,
        price: (raw['price'] as num? ?? 0).toDouble(),
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
