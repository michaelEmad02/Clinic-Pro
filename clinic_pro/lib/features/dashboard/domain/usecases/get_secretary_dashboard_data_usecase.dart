import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/secretary_dashboard_data_entity.dart';
import '../repositories/i_secretary_dashboard_repository.dart';

class GetSecretaryDashboardDataParams extends Equatable {
  final String secretaryId;
  final String clinicId;
  final String? secretaryName;
  final String? clinicName;

  const GetSecretaryDashboardDataParams({
    required this.secretaryId,
    required this.clinicId,
    this.secretaryName,
    this.clinicName,
  });

  @override
  List<Object?> get props => [secretaryId, clinicId, secretaryName, clinicName];
}

@lazySingleton
class GetSecretaryDashboardDataUseCase {
  final ISecretaryDashboardRepository _repository;

  GetSecretaryDashboardDataUseCase(this._repository);

  Future<Either<Failure, SecretaryDashboardDataEntity>> call(
    GetSecretaryDashboardDataParams params,
  ) {
    return _repository.getSecretaryDashboardData(
      secretaryId: params.secretaryId,
      clinicId: params.clinicId,
      secretaryName: params.secretaryName,
      clinicName: params.clinicName,
    );
  }
}
