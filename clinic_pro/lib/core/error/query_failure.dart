// ────────────────────────────────────────────────────────
// أخطاء استعلامات قاعدة البيانات (QueryFailure)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class QueryFailure extends Failure {
  const QueryFailure({required String message}) : super(message);

  factory QueryFailure.fromException(Object e) {
    if (e is PostgrestException) {
      return QueryFailure.fromPostgrestException(e);
    }
    
    // معالجة أخطاء الشبكة والاتصال العام بقاعدة البيانات
    final message = e.toString();
    if (message.contains('socket') ||
        message.contains('Network') ||
        message.contains('network') ||
        message.contains('Failed host lookup') ||
        message.contains('Timeout')) {
      return const NetworkQueryFailure();
    }

    return UnknownQueryFailure(message: message);
  }

  factory QueryFailure.fromPostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return const UniqueViolationFailure();
      case '23503':
        return const ForeignKeyViolationFailure();
      case '23502':
        return const NotNullViolationFailure();
      case '42P01':
        return const UndefinedTableFailure();
      case '42703':
        return const UndefinedColumnFailure();
      case '42501':
        return const InsufficientPrivilegesFailure();
      case '57014':
        return const QueryTimeoutFailure();
      case 'PGRST116':
        return const RecordNotFoundFailure();
    }

    return UnknownQueryFailure(
      message: e.message,
      code: e.code,
      details: e.details,
      hint: e.hint,
    );
  }
}

class UniqueViolationFailure extends QueryFailure {
  const UniqueViolationFailure()
      : super(message: 'هذا السجل موجود مسبقاً.');
}

class ForeignKeyViolationFailure extends QueryFailure {
  const ForeignKeyViolationFailure()
      : super(message: 'بيانات مرجعية غير موجودة.');
}

class NotNullViolationFailure extends QueryFailure {
  const NotNullViolationFailure()
      : super(message: 'حقل مطلوب لا يمكن أن يكون فارغاً.');
}

class UndefinedTableFailure extends QueryFailure {
  const UndefinedTableFailure()
      : super(message: 'خطأ في قاعدة البيانات: الجدول غير موجود.');
}

class UndefinedColumnFailure extends QueryFailure {
  const UndefinedColumnFailure()
      : super(message: 'خطأ في قاعدة البيانات: العمود غير موجود.');
}

class InsufficientPrivilegesFailure extends QueryFailure {
  const InsufficientPrivilegesFailure()
      : super(message: 'ليس لديك الصلاحية الكافية لإتمام هذا الإجراء.');
}

class QueryTimeoutFailure extends QueryFailure {
  const QueryTimeoutFailure()
      : super(message: 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.');
}

class NetworkQueryFailure extends QueryFailure {
  const NetworkQueryFailure()
      : super(message: 'عفواً، لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.');
}

class RecordNotFoundFailure extends QueryFailure {
  const RecordNotFoundFailure()
      : super(message: 'لم يتم العثور على السجل المطلوب.');
}

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
