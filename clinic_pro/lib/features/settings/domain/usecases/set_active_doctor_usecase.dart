// ────────────────────────────────────────────────────────
// UseCase: تغيير وتعيين الطبيب النشط للسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class SetActiveDoctorUseCase {
  final ISettingsRepository _repository;
  SetActiveDoctorUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String secretaryId,
    required String clinicId,
    required String doctorId,
  }) {
    return _repository.setSecretaryActiveDoctor(
      secretaryId: secretaryId,
      clinicId: clinicId,
      doctorId: doctorId,
    );
  }
}
