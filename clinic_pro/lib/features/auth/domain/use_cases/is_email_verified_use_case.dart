// ────────────────────────────────────────────────────────
// UseCase للتحقق من حالة تفعيل البريد الإلكتروني (IsEmailVerifiedUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class IsEmailVerifiedUseCase {
  final IAuthRepository _repository;

  IsEmailVerifiedUseCase(this._repository);

  Future<Either<Failure, bool>> call(String email) {
    return _repository.isEmailVerified(email);
  }
}
