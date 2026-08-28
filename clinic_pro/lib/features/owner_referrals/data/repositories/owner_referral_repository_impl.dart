// ─────────────────────────────────────────────────────────────────────────────
// تنفيذ مستودع إحالات الملاك (Owner Referral Repository Implementation)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/owner_referrals/data/data_sources/owner_referral_remote_data_source.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';
import 'package:clinic_pro/features/owner_referrals/domain/repositories/owner_referral_repository.dart';

@LazySingleton(as: IOwnerReferralRepository)
class OwnerReferralRepositoryImpl implements IOwnerReferralRepository {
  final IOwnerReferralRemoteDataSource _remoteDataSource;

  OwnerReferralRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ReferralDashboardEntity>> getReferralDashboard(
      String ownerId) async {
    try {
      final dashboard = await _remoteDataSource.getReferralDashboard(ownerId);
      return Right(dashboard);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ApplyReferralResultEntity>> applyReferralCodeOnRegistration({
    required String referralCode,
    required String newOwnerId,
  }) async {
    try {
      final result = await _remoteDataSource.applyReferralCodeOnRegistration(
        referralCode: referralCode,
        newOwnerId: newOwnerId,
      );
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
