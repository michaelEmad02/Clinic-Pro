// ────────────────────────────────────────────────────────
// واجهة مستودع التحقق من الهوية والمصادقة (IAuthRepository)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';

abstract class IAuthRepository {
  /// جلب بيانات المستخدم الحالي والكشف عن دوره وصلاحياته (owner, doctor, secretary)
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser();

  /// تسجيل الدخول باستخدام Google
  Future<Either<Failure, AuthUserEntity>> loginWithGoogle();

  /// تسجيل الدخول باستخدام Apple
  Future<Either<Failure, AuthUserEntity>> loginWithApple();

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<Either<Failure, AuthUserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// إرسال رابط الدخول السحري (Magic Link) إلى البريد الإلكتروني
  Future<Either<Failure, Unit>> sendMagicLink(String email);

  /// تسجيل مالك عيادة جديد بالكامل في النظام
  Future<Either<Failure, AuthUserEntity>> registerOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  });

  /// جلب تفاصيل الدعوة بناءً على الرمز الفريد (Token)
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(String token);

  /// قبول الدعوة والانضمام رسمياً إلى طاقم العيادة
  Future<Either<Failure, Unit>> acceptInvitation(String token);

  /// التحقق من البريد الإلكتروني باستخدام رمز التحقق (OTP/Token)
  Future<Either<Failure, AuthUserEntity>> verifyEmail({
    required String email,
    required String token,
  });

  /// التحقق مما إذا كان البريد الإلكتروني قد تم تفعيله بالفعل
  Future<Either<Failure, bool>> isEmailVerified(String email);

  /// تسجيل الخروج من النظام وإنهاء الجلسة
  Future<Either<Failure, Unit>> logout();
}
