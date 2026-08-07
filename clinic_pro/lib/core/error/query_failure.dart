import 'dart:async';
import 'dart:io';

import 'package:clinic_pro/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class QueryFailure extends Failure {
  const QueryFailure({required String message}) : super(message);

  factory QueryFailure.fromException(Object e) {
    if (e is PostgrestException) {
      return QueryFailure.fromPostgrestException(e);
    }
    if (e is SocketException) {
      return const NetworkQueryFailure();
    }
    if (e is TimeoutException) {
      return const QueryTimeoutFailure();
    }
    if (e is FormatException) {
      return const FormatQueryFailure();
    }

    // معالجة نصية عامة لأخطاء الشبكة والقيود والصلاحيات
    final message = e.toString();
    if (message.contains('socket') ||
        message.contains('Network') ||
        message.contains('network') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection refused') ||
        message.contains('Connection reset') ||
        message.contains('ClientException')) {
      return const NetworkQueryFailure();
    }
    if (message.contains('Timeout') || message.contains('timed out')) {
      return const QueryTimeoutFailure();
    }
    if (message.contains('invalid input syntax for type uuid') ||
        message.contains('22P02')) {
      return const InvalidUuidFailure();
    }
    if (message.contains('row-level security') ||
        message.contains('RLS') ||
        message.contains('permission denied') ||
        message.contains('insufficient_privilege') ||
        message.contains('42501')) {
      return const InsufficientPrivilegesFailure();
    }
    if (message.contains('JWT expired') ||
        message.contains('token expired') ||
        message.contains('PGRST301')) {
      return const JWTExpiredFailure();
    }

    return UnknownQueryFailure(message: message);
  }

  factory QueryFailure.fromPostgrestException(PostgrestException e) {
    switch (e.code) {
      // Data/Constraint Violations
      case '23505':
        return const UniqueViolationFailure();
      case '23503':
        return const ForeignKeyViolationFailure();
      case '23502':
        return const NotNullViolationFailure();
      case '23514':
        return const CheckConstraintViolationFailure();
      case '22P02':
        return const InvalidUuidFailure();
      case '22001':
        return const StringDataRightTruncationFailure();
      case '22007':
      case '22008':
        return const InvalidDateTimeFormatFailure();

      // Schema/Structure Errors
      case '42P01':
        return const UndefinedTableFailure();
      case '42703':
        return const UndefinedColumnFailure();

      // Permission, Authorization & Security (RLS & Grants)
      case '42501': // permission_denied (RLS policy constraint)
      case '28000': // invalid_authorization_specification
      case '28P01': // invalid_password
      case '42000': // syntax_error_or_access_rule_violation
        return const InsufficientPrivilegesFailure();

      case '42601':
        return const SyntaxErrorQueryFailure();

      // Timeouts & Resources
      case '57014':
      case '57P01':
        return const QueryTimeoutFailure();
      case '53300':
        return const TooManyConnectionsFailure();

      // PostgREST RESTful API Errors
      case 'PGRST116':
        return const RecordNotFoundFailure();
      case 'PGRST200':
      case 'PGRST204':
        return const AmbiguousEmbedFailure();
      case 'PGRST301':
      case 'PGRST302':
        return const JWTExpiredFailure();
      case 'PGRST300':
        return const UnauthorizedApiFailure();
    }

    // فحص إضافي في حالة وصول الرسالة تحتوي نص RLS
    final msg = e.message.toLowerCase();
    if (msg.contains('row-level security') ||
        msg.contains('permission denied') ||
        msg.contains('policy')) {
      return const InsufficientPrivilegesFailure();
    }

    return UnknownQueryFailure(
      message: e.message,
      code: e.code,
      details: e.details,
      hint: e.hint,
    );
  }
}

// ─── PostgREST & Database Failures ──────────────────────────

class UniqueViolationFailure extends QueryFailure {
  const UniqueViolationFailure() : super(message: 'هذا السجل موجود مسبقاً.');
}

class ForeignKeyViolationFailure extends QueryFailure {
  const ForeignKeyViolationFailure() : super(message: 'بيانات مرجعية غير موجودة.');
}

class NotNullViolationFailure extends QueryFailure {
  const NotNullViolationFailure() : super(message: 'حقل مطلوب لا يمكن أن يكون فارغاً.');
}

class CheckConstraintViolationFailure extends QueryFailure {
  const CheckConstraintViolationFailure() : super(message: 'البيانات المدخلة تخالف شروط الصحة المحددة.');
}

class UndefinedTableFailure extends QueryFailure {
  const UndefinedTableFailure() : super(message: 'خطأ في قاعدة البيانات: الجدول غير موجود.');
}

class UndefinedColumnFailure extends QueryFailure {
  const UndefinedColumnFailure() : super(message: 'خطأ في قاعدة البيانات: العمود غير موجود.');
}

class InsufficientPrivilegesFailure extends QueryFailure {
  const InsufficientPrivilegesFailure() : super(message: 'ليس لديك الصلاحية الكافية لإتمام هذا الإجراء.');
}

class SyntaxErrorQueryFailure extends QueryFailure {
  const SyntaxErrorQueryFailure() : super(message: 'خطأ في صياغة استعلام قاعدة البيانات.');
}

class StringDataRightTruncationFailure extends QueryFailure {
  const StringDataRightTruncationFailure() : super(message: 'النص المدخل أطول من الحد المسموح به للحقل.');
}

class InvalidDateTimeFormatFailure extends QueryFailure {
  const InvalidDateTimeFormatFailure() : super(message: 'صيغة التاريخ أو الوقت غير صحيحة.');
}

class TooManyConnectionsFailure extends QueryFailure {
  const TooManyConnectionsFailure() : super(message: 'الخادم مشغول حالياً بسبب كثرة الاتصالات. أعد المحاولة لاحقاً.');
}

class AmbiguousEmbedFailure extends QueryFailure {
  const AmbiguousEmbedFailure() : super(message: 'خطأ في ربط الجداول: توجد علاقات متعددة متضاربة.');
}

class QueryTimeoutFailure extends QueryFailure {
  const QueryTimeoutFailure() : super(message: 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.');
}

class NetworkQueryFailure extends QueryFailure {
  const NetworkQueryFailure() : super(message: 'عفواً، لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.');
}

class FormatQueryFailure extends QueryFailure {
  const FormatQueryFailure() : super(message: 'حدث خطأ في معالجة أو تنسيق البيانات إرجاعاً.');
}

class RecordNotFoundFailure extends QueryFailure {
  const RecordNotFoundFailure() : super(message: 'لم يتم العثور على السجل المطلوب.');
}

class InvalidUuidFailure extends QueryFailure {
  const InvalidUuidFailure() : super(message: 'المعرف الممرر غير صالح (UUID غير صحيح).');
}

class JWTExpiredFailure extends QueryFailure {
  const JWTExpiredFailure() : super(message: 'انتهت جلسة تسجيل الدخول. يرجى إعادة تسجيل الدخول.');
}

class UnauthorizedApiFailure extends QueryFailure {
  const UnauthorizedApiFailure() : super(message: 'غير مصرح لك بالوصول إلى هذا المورد.');
}

// ─── Unknown / Fallback Failure ──────────────────────────────

class UnknownQueryFailure extends QueryFailure {
  final String? code;
  final Object? details;
  final String? hint;

  const UnknownQueryFailure({
    required super.message,
    this.code,
    this.details,
    this.hint,
  });
}
