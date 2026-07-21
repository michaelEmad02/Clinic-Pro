// ────────────────────────────────────────────────────────
// UseCase: تحديث بيانات العيادة (خاص بالمالك)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UpdateClinicInfoUseCase {
  final ISettingsRepository _repository;
  UpdateClinicInfoUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String clinicId,
    required String name,
    required String address,
    required String phone1,
    String? phone2,
    String? logoUrl,
  }) {
    return _repository.updateClinicInfo(
      clinicId: clinicId,
      name: name,
      address: address,
      phone1: phone1,
      phone2: phone2,
      logoUrl: logoUrl,
    );
  }
}
