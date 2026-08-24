// ────────────────────────────────────────────────────────
// نموذج حالة الدفع (PaymentStatusModel)
// ────────────────────────────────────────────────────────

import '../../domain/entities/payment_status_entity.dart';

class PaymentStatusModel extends PaymentStatusEntity {
  const PaymentStatusModel({
    required super.transactionId,
    super.referenceNumber,
    super.gatewayOrderId,
    super.fawryCode,
    required super.status,
    required super.paymentMethod,
    required super.amount,
    required super.currency,
    super.errorMessage,
    super.subscriptionId,
    super.subscriptionStatus,
    super.subscriptionType,
    super.planId,
    super.startedAt,
    super.endAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      transactionId: json['transaction_id'] as String? ?? '',
      referenceNumber: json['reference_number'] as String?,
      gatewayOrderId: json['gateway_order_id'] as String?,
      fawryCode: json['fawry_code'] as String?,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'card',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EGP',
      errorMessage: json['error_message'] as String?,
      subscriptionId: json['subscription_id'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionType: json['subscription_type'] as String?,
      planId: json['plan_id'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      endAt: json['end_at'] != null
          ? DateTime.tryParse(json['end_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'status': status,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency': currency,
      'error_message': errorMessage,
      'subscription_id': subscriptionId,
      'subscription_status': subscriptionStatus,
      'subscription_type': subscriptionType,
      'plan_id': planId,
      'started_at': startedAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
    };
  }
}
