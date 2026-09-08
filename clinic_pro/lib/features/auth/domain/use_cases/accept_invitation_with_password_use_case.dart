// ────────────────────────────────────────────────────────
// UseCase لقبول الدعوة بالبريد وكلمة المرور (AcceptInvitationWithPasswordUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class AcceptInvitationWithPasswordUseCase {
  final IAuthRepository _repository;

  AcceptInvitationWithPasswordUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String token,
    required String email,
    required String password,
    String? name,
    String? phone,
    String? address,
    String? specialty,
  }) {
    return _repository.acceptInvitationWithPassword(
      token: token,
      email: email,
      password: password,
      name: name,
      phone: phone,
      address: address,
      specialty: specialty,
    );
  }
}
