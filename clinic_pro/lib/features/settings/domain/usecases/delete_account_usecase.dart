import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@lazySingleton
class DeleteAccountUseCase {
  final ISettingsRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String userId) {
    return _repository.deleteAccount(userId);
  }
}
