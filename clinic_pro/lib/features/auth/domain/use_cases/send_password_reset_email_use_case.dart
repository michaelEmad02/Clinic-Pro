// ────────────────────────────────────────────────────────
// حالة الاستخدام لإرسال رابط إعادة تعيين كلمة المرور (SendPasswordResetEmailUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

@lazySingleton
class SendPasswordResetEmailUseCase {
  final IAuthRepository _repository;

  SendPasswordResetEmailUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String email) async {
    return await _repository.sendPasswordResetEmail(email);
  }
}
