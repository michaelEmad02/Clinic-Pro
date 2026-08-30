// ────────────────────────────────────────────────────────
// أخطاء المصادقة (AuthFailure)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthFailure extends Failure {
  const AuthFailure([super.customMessage]);

  factory AuthFailure.fromException(Object e) {
    if (e is AuthException) {
      return AuthFailure.fromAuthException(e);
    }

    final message = e.toString();
    if (message.contains('UserNotFound') || message.contains('لم يتم العثور')) {
      return const UserNotFoundFailure();
    }
    if (message.contains('NotAuthenticated') || message.contains('تسجيل الدخول')) {
      return const NotAuthenticatedFailure();
    }
    if (message.contains('InvitationNotFound') || message.contains('الدعوة')) {
      return const InvitationNotFoundFailure();
    }
    if (message.contains('socket') ||
        message.contains('Network') ||
        message.contains('network') ||
        message.contains('Failed host lookup') ||
        message.contains('Timeout')) {
      return const NetworkAuthFailure();
    }

    return UnknownAuthFailure(message);
  }

  factory AuthFailure.fromAuthException(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return const InvalidCredentialsFailure();
      case 'user_not_found':
        return const UserNotFoundFailure();
      case 'user_already_exists':
      case 'email_exists':
        return const EmailAlreadyInUseFailure();
      case 'weak_password':
        return const WeakPasswordFailure();
      case 'over_email_send_rate_limit':
      case 'email_rate_limit_exceeded':
        return UnknownAuthFailure(e.message);
      case 'email_not_confirmed':
        return const EmailNotVerifiedFailure();
      case 'bad_jwt':
      case 'session_not_found':
        return const NotAuthenticatedFailure();
      case 'user_banned':
        return UnknownAuthFailure(e.message);
      case 'invalid_grant':
        return const InvalidCredentialsFailure();
      case 'validation_failed':
        if (e.message.contains('email') || e.message.contains('بريد')) {
          return const InvalidEmailFailure();
        }
        if (e.message.contains('password') ||
            e.message.contains('كلمة المرور')) {
          return const WeakPasswordFailure();
        }
        return UnknownAuthFailure(e.message);
    }

    if (e.message.contains('Invalid login credentials') ||
        e.message.contains('invalid_grant')) {
      return const InvalidCredentialsFailure();
    }
    if (e.message.contains('User already registered') ||
        e.message.contains('already exists')) {
      return const EmailAlreadyInUseFailure();
    }
    if (e.message.contains('Email not confirmed')) {
      return const EmailNotVerifiedFailure();
    }
    if (e.message.contains('Password should be') ||
        e.message.contains('weak_password')) {
      return const WeakPasswordFailure();
    }
    if (e.message.contains('SocketException') ||
        e.message.contains('Network') ||
        e.message.contains('network') ||
        e.message.contains('Timeout')) {
      return const NetworkAuthFailure();
    }

    return UnknownAuthFailure(e.message);
  }
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invalidCredentials;
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.userNotFound;
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.emailAlreadyInUse;
}

class WeakPasswordFailure extends AuthFailure {
  final List<String>? reasons;

  const WeakPasswordFailure([super.customMessage]) : reasons = null;

  WeakPasswordFailure.withReasons(List<String> reasonsList)
      : reasons = reasonsList,
        super(FailureStrings.weakPasswordWithReasons(reasonsList));

  @override
  String get defaultMessage => FailureStrings.weakPassword;
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invalidEmail;
}

class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.emailNotVerified;
}

class InvitationNotFoundFailure extends AuthFailure {
  const InvitationNotFoundFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invitationNotFound;
}

class NotAuthenticatedFailure extends AuthFailure {
  const NotAuthenticatedFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.notAuthenticated;
}

class GoogleSignInFailure extends AuthFailure {
  const GoogleSignInFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.googleSignInFailed;
}

class AppleSignInFailure extends AuthFailure {
  const AppleSignInFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.appleSignInFailed;
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.networkError;
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([super.customMessage]);
}
