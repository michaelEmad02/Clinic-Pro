// ────────────────────────────────────────────────────────
// أخطاء التخزين (StorageFailure)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StorageFailure extends Failure {
  const StorageFailure({required String message}) : super(message);

  factory StorageFailure.fromException(Object e) {
    if (e is StorageException) {
      return StorageFailure.fromStorageException(e);
    }
    return UnknownStorageFailure(message: e.toString());
  }

  factory StorageFailure.fromStorageException(StorageException e) {
    if (e.statusCode == '404') {
      return const FileNotFoundFailure();
    }
    if (e.statusCode == '409') {
      return const FileAlreadyExistsFailure();
    }
    if (e.statusCode == '413') {
      return const FileTooLargeFailure();
    }
    if (e.statusCode == '400') {
      return const InvalidFileFailure();
    }

    return UnknownStorageFailure(
      message: e.message,
      error: e.error,
      statusCode: e.statusCode,
    );
  }
}

class FileNotFoundFailure extends StorageFailure {
  const FileNotFoundFailure([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.fileNotFound : super.message;
}

class FileAlreadyExistsFailure extends StorageFailure {
  const FileAlreadyExistsFailure([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.fileAlreadyExists : super.message;
}

class FileTooLargeFailure extends StorageFailure {
  const FileTooLargeFailure([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.fileTooLarge : super.message;
}

class InvalidFileFailure extends StorageFailure {
  const InvalidFileFailure([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.invalidFile : super.message;
}

class UnknownStorageFailure extends StorageFailure {
  final String? error;
  final String? statusCode;

  const UnknownStorageFailure({
    required super.message,
    this.error,
    this.statusCode,
  });
}
