// ─────────────────────────────────────────────────────────────────────────────
// تنفيذ مستودع الكوبونات (Coupons Repository Implementation)
// يربط طبقة البيانات بطبقة النطاق ويعالج الأخطاء بنمط Either<Failure, T>
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/coupons/data/data_sources/coupons_remote_data_source.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';
import 'package:clinic_pro/features/coupons/domain/repositories/coupons_repository.dart';

@LazySingleton(as: ICouponsRepository)
class CouponsRepositoryImpl implements ICouponsRepository {
  final ICouponsRemoteDataSource _remoteDataSource;

  CouponsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CouponValidationResultEntity>> validateCoupon({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  }) async {
    try {
      final result = await _remoteDataSource.validateCoupon(
        code: code,
        ownerId: ownerId,
        planId: planId,
        billingCycle: billingCycle,
      );
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<CouponEntity>>> getAvailableCoupons(
      String ownerId) async {
    try {
      final coupons = await _remoteDataSource.getAvailableCoupons(ownerId);
      return Right(coupons);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> redeemCoupon({
    required String couponId,
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
    String? transactionId,
  }) async {
    try {
      await _remoteDataSource.redeemCoupon(
        couponId: couponId,
        ownerId: ownerId,
        planId: planId,
        billingCycle: billingCycle,
        transactionId: transactionId,
      );
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
