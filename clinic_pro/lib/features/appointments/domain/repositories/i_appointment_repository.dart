// ────────────────────────────────────────────────────────
// واجهة مستودع المواعيد (IAppointmentRepository)
// تُعرّف العمليات الأساسية المتاحة لإدارة المواعيد وطابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_entity.dart';

abstract class IAppointmentRepository {
  /// جلب مواعيد عيادة في تاريخ معين (أو جميعها) مع إمكانية التصفية بحسب الطبيب أو الحالة
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  });

  /// جلب موعد محدد باستخدام المعرف الخاص به
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String id);

  /// إضافة موعد جديد
  Future<Either<Failure, AppointmentEntity>> addAppointment(AppointmentEntity appointment);

  /// تأكيد وصول المريض (تغيير الحالة إلى confirmed وتسجيل وقت الوصول)
  Future<Either<Failure, Unit>> confirmArrival(String appointmentId);

  /// استدعاء المريض (تغيير الحالة إلى in_progress وتسجيل وقت الاستدعاء)
  Future<Either<Failure, Unit>> callPatient(String appointmentId);

  /// تحديث حالة الموعد
  Future<Either<Failure, Unit>> updateStatus({
    required String appointmentId,
    required String newStatus,
  });

  /// إلغاء موعد قائم
  Future<Either<Failure, Unit>> cancelAppointment(String appointmentId);

  /// تغيير حالة الاستعجال للموعد
  Future<Either<Failure, Unit>> toggleUrgent({
    required String appointmentId,
    required bool isUrgent,
  });

  /// تعديل بيانات الموعد بالكامل
  Future<Either<Failure, Unit>> updateAppointment(AppointmentEntity appointment);

  /// حذف الموعد نهائياً من قاعدة البيانات
  Future<Either<Failure, Unit>> deleteAppointment(String appointmentId);

  /// الاشتراك في تحديثات المواعيد اللحظية
  Stream<List<AppointmentEntity>> subscribeAppointments({
    required String clinicId,
    String? doctorId,
  });
}
