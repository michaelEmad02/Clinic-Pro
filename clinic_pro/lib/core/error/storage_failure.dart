// ────────────────────────────────────────────────────────
// أخطاء التخزين (StorageFailure)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
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
  const FileNotFoundFailure()
      : super(message: 'الملف غير موجود.');
}

class FileAlreadyExistsFailure extends StorageFailure {
  const FileAlreadyExistsFailure()
      : super(message: 'الملف موجود مسبقاً.');
}

class FileTooLargeFailure extends StorageFailure {
  const FileTooLargeFailure()
      : super(message: 'حجم الملف كبير جداً.');
}

class InvalidFileFailure extends StorageFailure {
  const InvalidFileFailure()
      : super(message: 'نوع الملف غير مدعوم.');
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
