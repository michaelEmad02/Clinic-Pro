// ────────────────────────────────────────────────────────
// UseCase: جلب العيادات المتاحة للمستخدم
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetAvailableClinicsUseCase {
  final ISettingsRepository _repository;
  GetAvailableClinicsUseCase(this._repository);

  Future<Either<Failure, List<ClinicEntity>>> call(String userId) {
    return _repository.getAvailableClinics(userId);
  }
}
