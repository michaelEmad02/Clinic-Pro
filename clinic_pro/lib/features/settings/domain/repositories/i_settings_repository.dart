// ────────────────────────────────────────────────────────
// واجهة مستودع الإعدادات (ISettingsRepository)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ISettingsRepository {
  /// جلب بيانات المستخدم الحالي
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile(String userId);

  /// جلب بيانات العيادة الحالية
  Future<Either<Failure, Map<String, dynamic>>> getClinicInfo(String clinicId);

  /// جلب العيادات المتاحة
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableClinics();

  /// جلب اشتراك مالك العيادة
  Future<Either<Failure, Map<String, dynamic>>> getSubscription(String ownerId);

  /// تحديث الملف الشخصي للمستخدم
  Future<Either<Failure, Unit>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? specialty,
  });

  /// جلب علاقة سكرتيرة بطبيب لعيادة معينة
  Future<Either<Failure, List<Map<String, dynamic>>>> getSecretaryDoctors(String secretaryId, String clinicId);

  /// تحديث الطبيب النشط للسكرتيرة (محلياً/في العلاقة)
  Future<Either<Failure, Unit>> setSecretaryActiveDoctor(String secretaryId, String clinicId, String doctorId);
}
