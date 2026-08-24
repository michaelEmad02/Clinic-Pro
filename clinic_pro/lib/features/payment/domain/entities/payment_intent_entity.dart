// ────────────────────────────────────────────────────────
// كيان نتيجة الدفعية (PaymentIntentEntity)
// ────────────────────────────────────────────────────────

class PaymentIntentEntity {
  final String paymentUrl;
  final String transactionId;
  final String orderId;
  final String referenceNumber;
  final String? fawryCode;
  final String subscriptionId;
  final double amount;
  final String currency;

  const PaymentIntentEntity({
    required this.paymentUrl,
    required this.transactionId,
    required this.orderId,
    required this.referenceNumber,
    this.fawryCode,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
  });
}
