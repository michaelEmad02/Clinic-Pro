// ────────────────────────────────────────────────────────
// UseCase لجلب بيانات المستخدم الحالي (GetCurrentUserUseCase)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user_entity.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, AuthUserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}
