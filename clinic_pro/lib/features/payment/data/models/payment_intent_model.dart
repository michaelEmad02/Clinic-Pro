// ────────────────────────────────────────────────────────
// نموذج نتيجة الدفع (PaymentIntentModel)
// ────────────────────────────────────────────────────────

import '../../domain/entities/payment_intent_entity.dart';

class PaymentIntentModel extends PaymentIntentEntity {
  const PaymentIntentModel({
    required super.paymentUrl,
    required super.transactionId,
    required super.orderId,
    required super.referenceNumber,
    super.fawryCode,
    required super.subscriptionId,
    required super.amount,
    required super.currency,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentModel(
      paymentUrl: json['payment_url'] as String? ?? '',
      transactionId: json['transaction_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      referenceNumber: json['reference_number'] as String? ?? '',
      fawryCode: json['fawry_code'] as String?,
      subscriptionId: json['subscription_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EGP',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_url': paymentUrl,
      'transaction_id': transactionId,
      'order_id': orderId,
      'reference_number': referenceNumber,
      'fawry_code': fawryCode,
      'subscription_id': subscriptionId,
      'amount': amount,
      'currency': currency,
    };
  }
}
