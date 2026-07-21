// ────────────────────────────────────────────────────────
// UseCase: جلب بيانات العيادة الحالية
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetClinicInfoUseCase {
  final ISettingsRepository _repository;
  GetClinicInfoUseCase(this._repository);

  Future<Either<Failure, ClinicEntity>> call(String clinicId) {
    return _repository.getClinicInfo(clinicId);
  }
}
