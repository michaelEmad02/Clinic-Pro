// ────────────────────────────────────────────────────────
// واجهة مستودع الإعدادات (ISettingsRepository)
// تُعرّف العمليات المتاحة لفيتشر الإعدادات حسب دور المستخدم
// ────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:clinic_pro/features/settings/domain/entities/doctor_appointment_type_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/doctor_schedule_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';

abstract class ISettingsRepository {
  // ──── مشترك بين جميع الأدوار ────

  /// تحديث الملف الشخصي للمستخدم (الاسم، الهاتف، التخصص)
  Future<Either<Failure, Unit>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? specialty,
    String? imageUrl,
  });

  /// رفع صورة شخصية جديدة وإرجاع الرابط العام
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
  });

  /// جلب بيانات العيادة الحالية
  Future<Either<Failure, ClinicEntity>> getClinicInfo(String clinicId);

  /// جلب العيادات المتاحة للمستخدم (من clinic_staff)
  Future<Either<Failure, List<ClinicEntity>>> getAvailableClinics(
      String userId);

  // ──── المالك (Owner) فقط ────

  /// تحديث بيانات العيادة (الاسم، العنوان، الهاتف، الشعار)
  Future<Either<Failure, Unit>> updateClinicInfo({
    required String clinicId,
    required String name,
    required String address,
    required String phone1,
    String? phone2,
    String? logoUrl,
  });

  /// جلب اشتراك المالك الحالي
  Future<Either<Failure, SubscriptionEntity?>> getSubscription(String ownerId);

  // ──── الطبيب (Doctor) فقط ────

  /// جلب قاعدة ترتيب الانتظار الحالية للطبيب
  Future<Either<Failure, QueueRuleEntity?>> getQueueRule({
    required String doctorId,
    required String clinicId,
  });

  /// إنشاء أو تعديل قاعدة الانتظار للطبيب
  Future<Either<Failure, Unit>> upsertQueueRule({
    required String doctorId,
    required String clinicId,
    required String queueSystem,
    required List<String> slots,
    required int cycleLength,
    int? avgVisitMinutes,
  });

  /// جلب ساعات عمل الطبيب بالعيادة
  Future<Either<Failure, List<DoctorScheduleEntity>>> getDoctorSchedules({
    required String doctorId,
    required String clinicId,
  });

  /// حفظ أو تحديث مواعيد ساعات عمل الطبيب
  Future<Either<Failure, Unit>> upsertDoctorSchedule(
      List<DoctorScheduleEntity> schedule);

  /// جلب تسعيرات الزيارات الخاصة بالطبيب بالعيادة
  Future<Either<Failure, List<DoctorAppointmentTypeEntity>>>
      getDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
  });

  /// جلب الأنواع العامة للزيارات المتاحة في النظام
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getGlobalAppointmentTypes();

  /// إضافة أو تحديث تسعيرة زيارة طبيب
  Future<Either<Failure, Unit>> upsertDoctorAppointmentType(
      DoctorAppointmentTypeEntity typePrice);

  /// مزامنة وحفظ جميع تسعيرات زيارات الطبيب (حذف القديم وإدخال الجديد)
  Future<Either<Failure, Unit>> syncDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
    required List<DoctorAppointmentTypeEntity> types,
  });

  // ──── السكرتير (Secretary) فقط ────

  /// جلب قائمة الأطباء المرتبطين بالسكرتيرة في العيادة الحالية
  Future<Either<Failure, List<Map<String, dynamic>>>> getSecretaryDoctors({
    required String secretaryId,
    required String clinicId,
  });

  /// تغيير وتعيين الطبيب النشط للسكرتيرة
  Future<Either<Failure, Unit>> setSecretaryActiveDoctor({
    required String secretaryId,
    required String clinicId,
    required String doctorId,
  });
}
