// ────────────────────────────────────────────────────────
// UseCase لإرسال رابط الدخول السحري (SendMagicLinkUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class SendMagicLinkUseCase {
  final IAuthRepository _repository;

  SendMagicLinkUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) {
    return _repository.sendMagicLink(email);
  }
}
