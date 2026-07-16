// ────────────────────────────────────────────────────────
// UseCase لتسجيل مالك جديد (RegisterOwnerUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class RegisterOwnerUseCase {
  final IAuthRepository _repository;

  RegisterOwnerUseCase(this._repository);

  Future<Either<Failure, AuthUserEntity>> call({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  }) {
    return _repository.registerOwner(
      email: email,
      password: password,
      name: name,
      phone: phone,
      country: country,
      address: address,
    );
  }
}
