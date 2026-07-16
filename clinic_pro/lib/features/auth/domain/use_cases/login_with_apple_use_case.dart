// ────────────────────────────────────────────────────────
// UseCase لتسجيل الدخول باستخدام Apple (LoginWithAppleUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class LoginWithAppleUseCase {
  final IAuthRepository _repository;

  LoginWithAppleUseCase(this._repository);

  Future<Either<Failure, AuthUserEntity>> call() {
    return _repository.loginWithApple();
  }
}
