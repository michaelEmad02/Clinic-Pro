// ────────────────────────────────────────────────────────
// كيان المعاملة المالية (PaymentTransactionEntity)
// يمثل عملية دفع واحدة مرتبطة باشتراك أو خدمة
// ────────────────────────────────────────────────────────

class PaymentTransactionEntity {
  final String id;
  final String subscriptionId;
  final String ownerId;
  final String gateway; // 'paymob'
  final String paymentMethod; // 'card' | 'wallet' | 'fawry'
  final String? gatewayOrderId;
  final String? gatewayTransactionId;
  final double amount;
  final String currency; // 'EGP' | 'USD'
  final String status; // 'pending' | 'success' | 'failed' | 'refunded'
  final String? errorMessage;
  final DateTime createdAt;

  const PaymentTransactionEntity({
    required this.id,
    required this.subscriptionId,
    required this.ownerId,
    required this.gateway,
    required this.paymentMethod,
    this.gatewayOrderId,
    this.gatewayTransactionId,
    required this.amount,
    required this.currency,
    required this.status,
    this.errorMessage,
    required this.createdAt,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}
