import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/utils/queue_sorter.dart';

@injectable
class AppointmentsRepository {
  final ICloudService _cloud;

  AppointmentsRepository(this._cloud);

  /// تحميل جميع المواعيد مع جلب العلاقات المرتبطة بها (المرضى وأنواع المواعيد)
  Future<List<Map<String, dynamic>>> loadAppointments() async {
    final appointments = await _cloud.select(table: 'appointments');
    final List<Map<String, dynamic>> enriched = [];

    for (final raw in appointments) {
      final patientId = raw['patient_id'];
      final typeId = raw['appointment_type_id'];

      // جلب بيانات المريض
      final patients = await _cloud.select(
        table: 'patients',
        eq: {'id': patientId},
      );
      final patient = patients.isNotEmpty ? patients.first : {'name': 'مريض غير معروف', 'phone': ''};

      // جلب بيانات نوع الموعد
      final types = await _cloud.select(
        table: 'appointment_types',
        eq: {'id': typeId},
      );
      final type = types.isNotEmpty ? types.first : {'name': 'كشف', 'price': 0.0};

      // التحقق من وجود روشتة أو فاتورة مرتبطة بالموعد
      final prescriptions = await _cloud.select(
        table: 'prescriptions',
        eq: {'appointment_id': raw['id']},
      );
      final invoices = await _cloud.select(
        table: 'invoices',
        eq: {'source_id': raw['id']},
      );

      enriched.add({
        ...raw,
        'patients': {
          'name': patient['name'],
          'phone': patient['phone'],
        },
        'appointment_types': {
          'name': type['name'],
          'price': type['price'],
        },
        'prescriptions': prescriptions,
        'invoices': invoices,
      });
    }

    return enriched;
  }

  /// إضافة موعد جديد بعد حساب السعر المتوقع تلقائياً
  Future<Map<String, dynamic>> addAppointment({
    required String patientId,
    required String doctorId,
    required String typeId,
    required String date,
    required String time,
    required bool isUrgent,
    String? notes,
  }) async {
    // جلب سعر نوع الموعد
    final types = await _cloud.select(
      table: 'appointment_types',
      eq: {'id': typeId},
    );
    final type = types.isNotEmpty ? types.first : {'price': 0.0};
    final price = (type['price'] as num).toDouble();

    final data = {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_type_id': typeId,
      'date': date,
      'time': time,
      'status': 'scheduled',
      'price': price,
      'is_urgent': isUrgent,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    };

    return await _cloud.insert(table: 'appointments', data: data);
  }

  /// تأكيد وصول المريض وتحديث وقت الوصول
  Future<void> confirmArrival(String id) async {
    await _cloud.update(
      table: 'appointments',
      data: {
        'status': 'confirmed',
        'arrived_at': DateTime.now().toIso8601String(),
      },
      matchColumn: 'id',
      matchValue: id,
    );
  }

  /// إلغاء الموعد
  Future<void> cancelAppointment(String id) async {
    await _cloud.update(
      table: 'appointments',
      data: {'status': 'cancelled'},
      matchColumn: 'id',
      matchValue: id,
    );

    // حذف أي فواتير مرتبطة بهذا الموعد نهائياً لتفادي التأثير على التقارير المالية
    await _cloud.delete(
      table: 'invoices',
      matchColumn: 'source_id',
      matchValue: id,
    );
  }

  /// حذف موعد نهائياً
  Future<void> deleteAppointment(String id) async {
    // حذف الموعد
    await _cloud.delete(
      table: 'appointments',
      matchColumn: 'id',
      matchValue: id,
    );

    // حذف الفواتير المرتبطة به إن وجدت (للاحتياط)
    await _cloud.delete(
      table: 'invoices',
      matchColumn: 'source_id',
      matchValue: id,
    );
  }

  /// تغيير حالة الموعد كطارئ أو عادي
  Future<void> toggleUrgent(String id, bool isUrgent) async {
    await _cloud.update(
      table: 'appointments',
      data: {'is_urgent': isUrgent},
      matchColumn: 'id',
      matchValue: id,
    );
  }

  /// تعديل بيانات موعد قائم (الطبيب، النوع، التاريخ، الوقت، الملاحظات، الاستعجال)
  Future<void> updateAppointment({
    required String appointmentId,
    required String doctorId,
    required String typeId,
    required String date,
    required String time,
    required bool isUrgent,
    String? notes,
  }) async {
    // جلب سعر نوع الموعد الجديد
    final types = await _cloud.select(
      table: 'appointment_types',
      eq: {'id': typeId},
    );
    final type = types.isNotEmpty ? types.first : {'price': 0.0};
    final price = (type['price'] as num).toDouble();

    await _cloud.update(
      table: 'appointments',
      data: {
        'doctor_id': doctorId,
        'appointment_type_id': typeId,
        'date': date,
        'time': time,
        'price': price,
        'is_urgent': isUrgent,
        'notes': notes,
      },
      matchColumn: 'id',
      matchValue: appointmentId,
    );
  }

  /// تحميل طابور الانتظار لليوم وترتيبه برمجياً
  Future<List<Map<String, dynamic>>> loadQueue(String doctorId, String date) async {
    final list = await loadAppointments();
    
    // تصفية المواعيد لليوم وللطبيب المحدد وللعيادة النشطة فقط التي وصلت ولم تلغَ ولم تنتهِ بعد
    final todayAppointments = list.where((a) {
      return a['doctor_id'] == doctorId &&
          a['clinic_id'] == AppConstants.activeClinicId &&
          a['date'] == date &&
          a['arrived_at'] != null &&
          a['status'] != 'cancelled' &&
          a['status'] != 'done';
    }).toList();

    // جلب قاعدة ترتيب الدور لطبيب العيادة الحالي
    final rules = await _cloud.select(
      table: 'doctor_queue_rules',
      eq: {'doctor_id': doctorId},
    );
    final slots = rules.isNotEmpty ? (rules.first['slots'] as List?)?.cast<String>() : <String>[];

    return QueueSorter.sort(
      appointments: todayAppointments,
      ruleSlots: slots,
    );
  }

  /// استدعاء المريض لتغيير حالته إلى قيد الفحص وتحديث وقت الاتصال
  /// ويقوم تلقائياً بإنهاء حالة المريض الحالي (إن وجد) إلى "منتهي"
  Future<void> callPatient(String appointmentId) async {
    // جلب الموعد المستهدف لمعرفة معرف الطبيب والتاريخ
    final targetAppt = await _cloud.select(
      table: 'appointments',
      eq: {'id': appointmentId},
    );

    if (targetAppt.isNotEmpty) {
      final doctorId = targetAppt.first['doctor_id'];
      final date = targetAppt.first['date'];

      // البحث عن أي مريض حالته قيد الفحص حالياً عند هذا الطبيب لإنهاء زيارته
      final activeInProg = await _cloud.select(
        table: 'appointments',
        eq: {
          'doctor_id': doctorId,
          'date': date,
          'status': 'in_progress',
        },
      );

      for (final appt in activeInProg) {
        await _cloud.update(
          table: 'appointments',
          data: {'status': 'done'},
          matchColumn: 'id',
          matchValue: appt['id'],
        );
      }
    }

    // تحديث المريض المستدعى الجديد إلى قيد الفحص
    await _cloud.update(
      table: 'appointments',
      data: {
        'status': 'in_progress',
        'called_at': DateTime.now().toIso8601String(),
      },
      matchColumn: 'id',
      matchValue: appointmentId,
    );
  }
}
