import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/secretary_dashboard_data_entity.dart';

abstract class ISecretaryDashboardRepository {
  Future<Either<Failure, SecretaryDashboardDataEntity>> getSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  });

  Stream<Either<Failure, SecretaryDashboardDataEntity>> watchSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  });
}
