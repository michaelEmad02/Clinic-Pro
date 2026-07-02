import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';

@injectable
class InvoicesRepository {
  final ICloudService _cloud;

  InvoicesRepository(this._cloud);

  /// تحميل جميع الفواتير من قاعدة البيانات وإثرائها ببيانات المرضى ونوع الموعد
  Future<List<Map<String, dynamic>>> loadInvoices() async {
    final invoices = await _cloud.select(table: 'invoices');
    final List<Map<String, dynamic>> enriched = [];

    for (final inv in invoices) {
      final patientId = inv['patient_id'];
      final appointmentId = inv['source_id'];

      // جلب اسم المريض من جدول المرضى
      final patients = await _cloud.select(
        table: 'patients',
        eq: {'id': patientId},
      );
      final patientName = patients.isNotEmpty
          ? patients.first['name']
          : (inv['patient_name'] ?? 'مريض غير معروف');

      // جلب نوع الموعد من جدول المواعيد وجدول أنواع المواعيد
      String apptTypeName = 'كشف';
      if (appointmentId != null) {
        final appointments = await _cloud.select(
          table: 'appointments',
          eq: {'id': appointmentId},
        );
        if (appointments.isNotEmpty) {
          final typeId = appointments.first['appointment_type_id'];
          final types = await _cloud.select(
            table: 'appointment_types',
            eq: {'id': typeId},
          );
          if (types.isNotEmpty) {
            apptTypeName = types.first['name'];
          }
        }
      }

      enriched.add({
        ...inv,
        'patient_name': patientName,
        'appointment_type': inv['appointment_type'] ?? apptTypeName,
      });
    }

    return enriched;
  }

  /// تحميل قائمة المرضى من قاعدة البيانات
  Future<List<Map<String, dynamic>>> loadPatients() async {
    return await _cloud.select(table: 'patients');
  }

  /// تحميل مواعيد المريض غير المفوترة بعد بغض النظر عن حالتها
  Future<List<Map<String, dynamic>>> loadAppointmentsForPatient(
      String patientId) async {
    final appointments = await _cloud.select(
      table: 'appointments',
      eq: {'patient_id': patientId},
    );
    final List<Map<String, dynamic>> enriched = [];

    for (final raw in appointments) {
      final typeId = raw['appointment_type_id'];
      final doctorId = raw['doctor_id'];

      // جلب بيانات نوع الموعد
      final types = await _cloud.select(
        table: 'appointment_types',
        eq: {'id': typeId},
      );
      final type =
          types.isNotEmpty ? types.first : {'name': 'كشف', 'price': 0.0};

      // جلب بيانات الطبيب
      final doctors = await _cloud.select(
        table: 'users',
        eq: {'id': doctorId},
      );
      final doctorName =
          doctors.isNotEmpty ? doctors.first['name'] : 'طبيب معالج';

      enriched.add({
        ...raw,
        'doctor_name': doctorName,
        'appointment_types': {
          'name': type['name'],
          'price': type['price'],
        },
      });
    }

    return enriched;
  }

  /// جلب بيانات موعد محدد مع نوع الموعد
  Future<Map<String, dynamic>?> getAppointment(String appointmentId) async {
    final list =
        await _cloud.select(table: 'appointments', eq: {'id': appointmentId});
    if (list.isEmpty) return null;
    final appt = list.first;

    final typeId = appt['appointment_type_id'];
    final doctorId = appt['doctor_id'];

    final types =
        await _cloud.select(table: 'appointment_types', eq: {'id': typeId});
    final type = types.isNotEmpty ? types.first : {'name': 'كشف', 'price': 0.0};

    final doctors = await _cloud.select(table: 'users', eq: {'id': doctorId});
    final doctorName =
        doctors.isNotEmpty ? doctors.first['name'] : 'طبيب معالج';

    return {
      ...appt,
      'doctor_name': doctorName,
      'appointment_types': {
        'name': type['name'],
        'price': type['price'],
      }
    };
  }

  /// جلب بيانات مريض محدد
  Future<Map<String, dynamic>?> getPatient(String patientId) async {
    final list = await _cloud.select(table: 'patients', eq: {'id': patientId});
    return list.isNotEmpty ? list.first : null;
  }

  /// إنشاء فاتورة جديدة وحفظها في قاعدة البيانات (بدون عمود الحالة status)
  Future<Map<String, dynamic>> createInvoice({
    required String patientId,
    required String patientName,
    required String appointmentType,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    final data = {
      'clinic_id': 'c-1',
      'patient_id': patientId,
      'source_id': sourceId,
      'source_type': 'appointment',
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payment_method': paymentMethod ?? 'cash',
      'created_at': DateTime.now().toIso8601String(),
      'created_by': 'u-sec-1',
    };

    return await _cloud.insert(table: 'invoices', data: data);
  }

  /// تحديث المبلغ المدفوع لفاتورة معينة
  Future<void> updatePaidAmount({
    required String invoiceId,
    required double newPaidAmount,
    String? paymentMethod,
  }) async {
    final updateData = <String, dynamic>{
      'paid_amount': newPaidAmount,
    };

    if (paymentMethod != null) {
      updateData['payment_method'] = paymentMethod;
    }

    await _cloud.update(
      table: 'invoices',
      data: updateData,
      matchColumn: 'id',
      matchValue: invoiceId,
    );
  }

  /// تحديث بيانات فاتورة قائمة
  Future<void> updateInvoice({
    required String invoiceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    final updateData = <String, dynamic>{
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
    };

    if (paymentMethod != null) {
      updateData['payment_method'] = paymentMethod;
    }

    await _cloud.update(
      table: 'invoices',
      data: updateData,
      matchColumn: 'id',
      matchValue: invoiceId,
    );
  }

  /// حذف فاتورة نهائياً
  Future<void> deleteInvoice(String id) async {
    await _cloud.delete(
      table: 'invoices',
      matchColumn: 'id',
      matchValue: id,
    );
  }
}
