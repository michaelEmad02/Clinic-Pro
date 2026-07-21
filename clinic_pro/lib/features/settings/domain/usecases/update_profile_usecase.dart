// ────────────────────────────────────────────────────────
// UseCase: تحديث الملف الشخصي للمستخدم
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UpdateProfileUseCase {
  final ISettingsRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? specialty,
    String? imageUrl,
  }) {
    return _repository.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      address: address,
      specialty: specialty,
      imageUrl: imageUrl,
    );
  }
}
