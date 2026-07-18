// ────────────────────────────────────────────────────────
// أخطاء المصادقة (AuthFailure)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);

  factory AuthFailure.fromException(Object e) {
    if (e is AuthException) {
      return AuthFailure.fromAuthException(e);
    }

    final message = e.toString();
    if (message.contains('لم يتم العثور على بيانات المستخدم')) {
      return const UserNotFoundFailure();
    }
    if (message.contains('يجب تسجيل الدخول')) {
      return const NotAuthenticatedFailure();
    }
    if (message.contains('الدعوة غير موجودة') ||
        message.contains('منتهية الصلاحية')) {
      return const InvitationNotFoundFailure();
    }
    if (message.contains('socket') ||
        message.contains('Network') ||
        message.contains('network') ||
        message.contains('Failed host lookup') ||
        message.contains('Timeout')) {
      return const NetworkAuthFailure();
    }

    return UnknownAuthFailure(message: message);
  }

  factory AuthFailure.fromAuthException(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return const InvalidCredentialsFailure();
      case 'weak_password':
        if (e is AuthWeakPasswordException && e.reasons.isNotEmpty) {
          return WeakPasswordFailure._withReasons(e.reasons);
        }
        return const WeakPasswordFailure();
      case 'email_not_confirmed':
        return const EmailNotVerifiedFailure();
      case 'email_exists':
      case 'user_already_exists':
        return const EmailAlreadyInUseFailure();
      case 'user_not_found':
        return const UserNotFoundFailure();
      case 'session_not_found':
      case 'session_missing':
      case 'session_expired':
        return const NotAuthenticatedFailure();
      case 'invite_not_found':
        return const InvitationNotFoundFailure();
      case 'validation_failed':
        if (e.message.contains('email') || e.message.contains('بريد')) {
          return const InvalidEmailFailure();
        }
        break;
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
      case 'request_timeout':
        return const NetworkAuthFailure();
      case 'provider_disabled':
        if (e.message.contains('Google')) {
          return const GoogleSignInFailure();
        }
        if (e.message.contains('Apple')) {
          return const AppleSignInFailure();
        }
        break;
    }

    if (e.message.contains('socket') ||
        e.message.contains('Network') ||
        e.message.contains('network') ||
        e.message.contains('Timeout')) {
      return const NetworkAuthFailure();
    }

    return UnknownAuthFailure(message: e.message);
  }
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة.');
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure()
      : super(message: 'لم يتم العثور على بيانات المستخدم.');
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure()
      : super(message: 'البريد الإلكتروني مستخدم بالفعل.');
}

class WeakPasswordFailure extends AuthFailure {
  final List<String>? reasons;

  const WeakPasswordFailure()
      : reasons = null,
        super(
            message:
                'كلمة المرور ضعيفة جداً. يجب أن تحتوي على 6 أحرف على الأقل.');

  WeakPasswordFailure._withReasons(List<String> reasonsList)
      : reasons = reasonsList,
        super(
          message:
              'كلمة المرور ضعيفة جداً:\n${reasonsList.map((r) => '• $r').join('\n')}',
        );
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure()
      : super(message: 'صيغة البريد الإلكتروني غير صالحة.');
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure()
      : super(
            message:
                'البريد الإلكتروني غير مفعل. يرجى التحقق من بريدك الإلكتروني.');
}

class InvitationNotFoundFailure extends AuthFailure {
  const InvitationNotFoundFailure()
      : super(message: 'الدعوة غير موجودة أو منتهية الصلاحية.');
}

class NotAuthenticatedFailure extends AuthFailure {
  const NotAuthenticatedFailure() : super(message: 'يجب تسجيل الدخول أولاً.');
}

class GoogleSignInFailure extends AuthFailure {
  const GoogleSignInFailure()
      : super(message: 'فشل تسجيل الدخول بحساب Google.');
}

class AppleSignInFailure extends AuthFailure {
  const AppleSignInFailure() : super(message: 'فشل تسجيل الدخول بحساب Apple.');
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure()
      : super(message: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({required super.message});
}
