// ────────────────────────────────────────────────────────
// UseCase: جلب أنواع الزيارات العامة في النظام
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetGlobalAppointmentTypesUseCase {
  final ISettingsRepository _repository;
  GetGlobalAppointmentTypesUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getGlobalAppointmentTypes();
  }
}
