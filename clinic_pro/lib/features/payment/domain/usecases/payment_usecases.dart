// ────────────────────────────────────────────────────────
// حالات الاستخدام الخاصة بالدفع (PaymentUseCases)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_intent_entity.dart';
import '../entities/payment_method.dart';
import '../entities/payment_status_entity.dart';
import '../repositories/i_payment_repository.dart';


@lazySingleton
class CreatePaymentIntentUseCase {
  final IPaymentRepository _repository;

  CreatePaymentIntentUseCase(this._repository);

  Future<Either<Failure, PaymentIntentEntity>> call({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
    String? couponCode,
  }) {
    return _repository.createPaymentIntent(
      ownerId: ownerId,
      planId: planId,
      subscriptionType: subscriptionType,
      paymentMethod: paymentMethod,
      walletNumber: walletNumber,
      couponCode: couponCode,
    );
  }
}

@lazySingleton
class CheckPaymentStatusUseCase {
  final IPaymentRepository _repository;

  CheckPaymentStatusUseCase(this._repository);

  Future<Either<Failure, PaymentStatusEntity>> call(String transactionId) {
    return _repository.checkPaymentStatus(transactionId);
  }
}

