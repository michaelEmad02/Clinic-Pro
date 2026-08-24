// ────────────────────────────────────────────────────────
// واجهة مستودع الدفع (IPaymentRepository)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_intent_entity.dart';
import '../entities/payment_method.dart';
import '../entities/payment_status_entity.dart';


abstract class IPaymentRepository {
  Future<Either<Failure, PaymentIntentEntity>> createPaymentIntent({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
  });

  Future<Either<Failure, PaymentStatusEntity>> checkPaymentStatus(
    String transactionId,
  );
}

