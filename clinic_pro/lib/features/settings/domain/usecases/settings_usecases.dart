// ────────────────────────────────────────────────────────
// UseCases لـ Settings Feature
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

class GetUserSettingsUseCase {
  final ISettingsRepository _repository;
  GetUserSettingsUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}

class UpdateProfileUseCase {
  final ISettingsRepository _repository;
  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String userId,
    required String name,
    required String phone,
    String? specialty,
  }) {
    return _repository.updateProfile(
      userId: userId,
      name: name,
      phone: phone,
      specialty: specialty,
    );
  }
}

class GetAvailableClinicsUseCase {
  final ISettingsRepository _repository;
  GetAvailableClinicsUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getAvailableClinics();
  }
}

class GetSecretaryDoctorScheduleUseCase {
  final ISettingsRepository _repository;
  GetSecretaryDoctorScheduleUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(String secretaryId, String clinicId) {
    return _repository.getSecretaryDoctors(secretaryId, clinicId);
  }
}
