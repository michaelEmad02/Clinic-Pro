// ────────────────────────────────────────────────────────
// تنفيذ مستودع الدفع (PaymentRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status_entity.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../data_sources/payment_remote_data_source.dart';


@LazySingleton(as: IPaymentRepository)
class PaymentRepositoryImpl implements IPaymentRepository {
  final IPaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PaymentIntentEntity>> createPaymentIntent({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
  }) async {
    try {
      final result = await _remoteDataSource.createPaymentIntent(
        ownerId: ownerId,
        planId: planId,
        subscriptionType: subscriptionType,
        paymentMethod: paymentMethod,
        walletNumber: walletNumber,
      );
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PaymentStatusEntity>> checkPaymentStatus(
      String transactionId) async {
    try {
      final result = await _remoteDataSource.checkPaymentStatus(transactionId);
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

