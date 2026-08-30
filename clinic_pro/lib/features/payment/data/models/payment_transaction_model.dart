// ────────────────────────────────────────────────────────
// نموذج المعاملة المالية (PaymentTransactionModel)
// ────────────────────────────────────────────────────────

import '../../domain/entities/payment_transaction_entity.dart';

class PaymentTransactionModel extends PaymentTransactionEntity {
  static DateTime _parseUtc(String s) {
    final parsed = DateTime.parse(s);
    if (parsed.isUtc) return parsed;
    return DateTime.utc(parsed.year, parsed.month, parsed.day,
        parsed.hour, parsed.minute, parsed.second,
        parsed.millisecond, parsed.microsecond);
  }

  final Map<String, dynamic>? metadata;

  const PaymentTransactionModel({
    required super.id,
    required super.subscriptionId,
    required super.ownerId,
    required super.gateway,
    required super.paymentMethod,
    super.gatewayOrderId,
    super.gatewayTransactionId,
    required super.amount,
    required super.currency,
    required super.status,
    super.errorMessage,
    required super.createdAt,
    this.metadata,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as String? ?? '',
      subscriptionId: json['subscription_id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      gateway: json['gateway'] as String? ?? 'paymob',
      paymentMethod: json['payment_method'] as String? ?? 'card',
      gatewayOrderId: json['gateway_order_id'] as String?,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EGP',
      status: json['status'] as String? ?? 'pending',
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? _parseUtc(json['created_at'] as String)
          : DateTime.now().toUtc(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
    );
  }

}
