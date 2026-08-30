import 'dart:async';
import 'dart:io';

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class QueryFailure extends Failure {
  const QueryFailure([super.customMessage]);

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
    if (message.contains('FEATURE_NOT_ALLOWED') || message.contains('40301')) {
      final parts = message.split('FEATURE_NOT_ALLOWED:');
      final key = parts.length > 1 ? parts[1].trim() : '';
      return FeatureNotAllowedFailure(featureKey: key);
    }
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
    final message = e.message;
    if (message.contains('FEATURE_NOT_ALLOWED') || message.contains('40301')) {
      final parts = message.split('FEATURE_NOT_ALLOWED:');
      final key = parts.length > 1 ? parts[1].trim() : '';
      return FeatureNotAllowedFailure(featureKey: key);
    }
    if (message.contains('PLAN_LIMIT_REACHED') || message.contains('40302')) {
      return const PlanLimitQueryFailure();
    }

    switch (e.code) {
      case '23505':
        return const UniqueViolationFailure();
      case '23503':
        return const ForeignKeyViolationFailure();
      case '23502':
        return const NotNullViolationFailure();
      case '23514':
        return const CheckConstraintViolationFailure();
      case '42P01':
        return const UndefinedTableFailure();
      case '42703':
        return const UndefinedColumnFailure();
      case '42501':
        return const InsufficientPrivilegesFailure();
      case '42601':
        return const SyntaxErrorQueryFailure();
      case '22001':
        return const StringDataRightTruncationFailure();
      case '22007':
      case '22008':
        return const InvalidDateTimeFormatFailure();
      case '53300':
        return const TooManyConnectionsFailure();
      case 'PGRST100':
      case 'PGRST101':
      case 'PGRST102':
        return const SyntaxErrorQueryFailure();
      case 'PGRST116':
        return const RecordNotFoundFailure();
      case 'PGRST200':
      case 'PGRST201':
        return const AmbiguousEmbedFailure();
      case 'PGRST301':
        return const JWTExpiredFailure();
      case '401':
      case 'PGRST300':
        return const UnauthorizedApiFailure();
      case '403':
        return const InsufficientPrivilegesFailure();
      case '404':
        return const RecordNotFoundFailure();
      case '504':
        return const QueryTimeoutFailure();
    }

    if (e.message.contains('duplicate key value') ||
        e.message.contains('already exists')) {
      return const UniqueViolationFailure();
    }
    if (e.message.contains('violates foreign key constraint')) {
      return const ForeignKeyViolationFailure();
    }
    if (e.message.contains('violates not-null constraint')) {
      return const NotNullViolationFailure();
    }
    if (e.message.contains('violates check constraint')) {
      return const CheckConstraintViolationFailure();
    }
    if (e.message.contains('permission denied') ||
        e.message.contains('row-level security')) {
      return const InsufficientPrivilegesFailure();
    }
    if (e.message.contains('JWT expired')) {
      return const JWTExpiredFailure();
    }
    if (e.message.contains('SocketException') ||
        e.message.contains('Network') ||
        e.message.contains('network') ||
        e.message.contains('Failed host lookup')) {
      return const NetworkQueryFailure();
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
  const UniqueViolationFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.uniqueViolation;
}

class ForeignKeyViolationFailure extends QueryFailure {
  const ForeignKeyViolationFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.foreignKeyViolation;
}

class NotNullViolationFailure extends QueryFailure {
  const NotNullViolationFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.notNullViolation;
}

class CheckConstraintViolationFailure extends QueryFailure {
  const CheckConstraintViolationFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.checkConstraintViolation;
}

class UndefinedTableFailure extends QueryFailure {
  const UndefinedTableFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.undefinedTable;
}

class UndefinedColumnFailure extends QueryFailure {
  const UndefinedColumnFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.undefinedColumn;
}

class InsufficientPrivilegesFailure extends QueryFailure {
  const InsufficientPrivilegesFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.insufficientPrivileges;
}

class SyntaxErrorQueryFailure extends QueryFailure {
  const SyntaxErrorQueryFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.syntaxError;
}

class StringDataRightTruncationFailure extends QueryFailure {
  const StringDataRightTruncationFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.stringDataRightTruncation;
}

class InvalidDateTimeFormatFailure extends QueryFailure {
  const InvalidDateTimeFormatFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invalidDateTimeFormat;
}

class TooManyConnectionsFailure extends QueryFailure {
  const TooManyConnectionsFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.tooManyConnections;
}

class AmbiguousEmbedFailure extends QueryFailure {
  const AmbiguousEmbedFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.ambiguousEmbed;
}

class QueryTimeoutFailure extends QueryFailure {
  const QueryTimeoutFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.queryTimeout;
}

class NetworkQueryFailure extends QueryFailure {
  const NetworkQueryFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.networkQuery;
}

class FormatQueryFailure extends QueryFailure {
  const FormatQueryFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.formatQuery;
}

class RecordNotFoundFailure extends QueryFailure {
  const RecordNotFoundFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.recordNotFound;
}

class InvalidUuidFailure extends QueryFailure {
  const InvalidUuidFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invalidUuid;
}

class JWTExpiredFailure extends QueryFailure {
  const JWTExpiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.jwtExpired;
}

class UnauthorizedApiFailure extends QueryFailure {
  const UnauthorizedApiFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.unauthorizedApi;
}

class PlanLimitQueryFailure extends QueryFailure {
  const PlanLimitQueryFailure({String? message}) : super(message ?? '');

  @override
  String get defaultMessage => FailureStrings.planLimitReached;
}

class FeatureNotAllowedFailure extends QueryFailure {
  final String featureKey;
  const FeatureNotAllowedFailure({
    String? message,
    this.featureKey = '',
  }) : super(message ?? '');

  @override
  String get defaultMessage => FailureStrings.featureNotAllowed;
}

// ─── Unknown / Fallback Failure ──────────────────────────────

class UnknownQueryFailure extends QueryFailure {
  final String? code;
  final Object? details;
  final String? hint;

  const UnknownQueryFailure({
    required String message,
    this.code,
    this.details,
    this.hint,
  }) : super(message);
}
