import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/secretary_dashboard_data_entity.dart';
import '../repositories/i_secretary_dashboard_repository.dart';
import 'get_secretary_dashboard_data_usecase.dart';

@lazySingleton
class WatchSecretaryDashboardDataUseCase {
  final ISecretaryDashboardRepository _repository;

  WatchSecretaryDashboardDataUseCase(this._repository);

  Stream<Either<Failure, SecretaryDashboardDataEntity>> call(
    GetSecretaryDashboardDataParams params,
  ) {
    return _repository.watchSecretaryDashboardData(
      secretaryId: params.secretaryId,
      clinicId: params.clinicId,
      secretaryName: params.secretaryName,
      clinicName: params.clinicName,
    );
  }
}
