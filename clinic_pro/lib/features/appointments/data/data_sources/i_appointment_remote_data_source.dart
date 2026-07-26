// ────────────────────────────────────────────────────────
// واجهة مصدر بيانات المواعيد (IAppointmentRemoteDataSource)
// تحدد العمليات الأساسية لجلب وإدارة بيانات المواعيد من الخادم السحابي
// ────────────────────────────────────────────────────────

import '../models/appointment_model.dart';

abstract class IAppointmentRemoteDataSource {
  /// جلب المواعيد المحددة للعيادة مع فلاتر اختيارية للطبيب والتاريخ والحالة
  Future<List<AppointmentModel>> getAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  });

  /// جلب موعد معين بناءً على معرفه الفريد
  Future<AppointmentModel> getAppointmentById(String id);

  /// إدخال موعد جديد في قاعدة البيانات
  Future<AppointmentModel> insertAppointment(AppointmentModel appointment);

  /// تحديث بيانات موعد موجود
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment);

  /// تحديث حالة الموعد وتفاصيل الوصول والاستدعاء
  Future<List<Map<String, dynamic>>> updateFields({
    required String appointmentId,
    required Map<String, dynamic> fields,
  });

  /// حذف موعد معين
  Future<void> deleteAppointment(String appointmentId);

  /// حذف الفواتير المرتبطة بموعد معين
  Future<void> deleteRelatedInvoices(String appointmentId);

  /// الاشتراك المباشر بالوقت الفعلي لتحديثات المواعيد
  Stream<List<Map<String, dynamic>>> subscribeAppointments({
    required String clinicId,
  });
}
