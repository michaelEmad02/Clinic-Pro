// ────────────────────────────────────────────────────────
// UseCase للتحقق من البريد الإلكتروني (VerifyEmailUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class VerifyEmailUseCase {
  final IAuthRepository _repository;

  VerifyEmailUseCase(this._repository);

  Future<Either<Failure, AuthUserEntity>> call({
    required String email,
    required String token,
  }) {
    return _repository.verifyEmail(
      email: email,
      token: token,
    );
  }
}
