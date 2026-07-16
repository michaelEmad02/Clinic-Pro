// ────────────────────────────────────────────────────────
// UseCase لتسجيل الخروج وإنهاء الجلسة (LogoutUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class LogoutUseCase {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
