// ────────────────────────────────────────────────────────
// حالة الاستخدام لتحديث كلمة المرور (UpdatePasswordUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@lazySingleton
class UpdatePasswordUseCase {
  final IAuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String newPassword) async {
    return await _repository.updatePassword(newPassword);
  }
}
