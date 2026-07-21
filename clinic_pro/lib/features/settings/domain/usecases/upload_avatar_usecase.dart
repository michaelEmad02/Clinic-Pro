// ────────────────────────────────────────────────────────
// UseCase: رفع صورة شخصية جديدة للمستخدم
// ────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UploadAvatarUseCase {
  final ISettingsRepository _repository;
  UploadAvatarUseCase(this._repository);

  /// يرفع الصورة ويُرجع الرابط العام (Public URL)
  Future<Either<Failure, String>> call({
    required String userId,
    required Uint8List fileBytes,
  }) {
    return _repository.uploadAvatar(
      userId: userId,
      fileBytes: fileBytes,
    );
  }
}
