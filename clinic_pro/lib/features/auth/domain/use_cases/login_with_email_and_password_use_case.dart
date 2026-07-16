// ────────────────────────────────────────────────────────
// UseCase لتسجيل الدخول بالبريد وكلمة المرور (LoginWithEmailAndPasswordUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class LoginWithEmailAndPasswordUseCase {
  final IAuthRepository _repository;

  LoginWithEmailAndPasswordUseCase(this._repository);

  Future<Either<Failure, AuthUserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
