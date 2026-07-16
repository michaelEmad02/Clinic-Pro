// ────────────────────────────────────────────────────────
// UseCase لجلب تفاصيل الدعوة بالرمز (GetInvitationByTokenUseCase)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@injectable
class GetInvitationByTokenUseCase {
  final IAuthRepository _repository;

  GetInvitationByTokenUseCase(this._repository);

  Future<Either<Failure, InvitationEntity>> call(String token) {
    return _repository.getInvitationByToken(token);
  }
}
