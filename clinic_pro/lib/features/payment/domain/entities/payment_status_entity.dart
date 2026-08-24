// ────────────────────────────────────────────────────────
// كيان حالة الدفع (PaymentStatusEntity)
// ────────────────────────────────────────────────────────

class PaymentStatusEntity {
  final String transactionId;
  final String? referenceNumber;
  final String? gatewayOrderId;
  final String? fawryCode;
  final String status; // pending / success / failed
  final String paymentMethod;
  final double amount;
  final String currency;
  final String? errorMessage;
  final String? subscriptionId;
  final String? subscriptionStatus;
  final String? subscriptionType;
  final String? planId;
  final DateTime? startedAt;
  final DateTime? endAt;

  const PaymentStatusEntity({
    required this.transactionId,
    this.referenceNumber,
    this.gatewayOrderId,
    this.fawryCode,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    required this.currency,
    this.errorMessage,
    this.subscriptionId,
    this.subscriptionStatus,
    this.subscriptionType,
    this.planId,
    this.startedAt,
    this.endAt,
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}
