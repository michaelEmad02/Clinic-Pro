// ────────────────────────────────────────────────────────
// UseCase لقبول الدعوة والانضمام (AcceptInvitationUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class AcceptInvitationUseCase {
  final IAuthRepository _repository;

  AcceptInvitationUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String token) {
    return _repository.acceptInvitation(token);
  }
}
