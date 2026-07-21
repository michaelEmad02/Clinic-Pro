// ────────────────────────────────────────────────────────
// UseCase: جلب الأطباء المرتبطين بالسكرتيرة في العيادة الحالية
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetSecretaryDoctorsUseCase {
  final ISettingsRepository _repository;
  GetSecretaryDoctorsUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call({
    required String secretaryId,
    required String clinicId,
  }) {
    return _repository.getSecretaryDoctors(
      secretaryId: secretaryId,
      clinicId: clinicId,
    );
  }
}
