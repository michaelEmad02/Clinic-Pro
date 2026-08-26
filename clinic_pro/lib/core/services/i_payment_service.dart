// ────────────────────────────────────────────────────────
// واجهة خدمة الدفع الخارجية (IPaymentService)
// ────────────────────────────────────────────────────────

import '../../features/payment/domain/entities/payment_intent_entity.dart';
import '../../features/payment/domain/entities/payment_method.dart';
import '../../features/payment/domain/entities/payment_status_entity.dart';

abstract class IPaymentService {
  Future<PaymentIntentEntity> createPaymentIntent({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
    String? couponCode,
  });

  Future<PaymentStatusEntity> checkPaymentStatus(String transactionId);
}
