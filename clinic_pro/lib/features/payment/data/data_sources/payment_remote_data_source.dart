// ────────────────────────────────────────────────────────
// مصدر بيانات الدفع البعيد (PaymentRemoteDataSource)
// يستدعي IPaymentService للتواصل مع Edge Functions
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../../../core/services/i_payment_service.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status_entity.dart';



abstract class IPaymentRemoteDataSource {
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


@LazySingleton(as: IPaymentRemoteDataSource)
class PaymentRemoteDataSource implements IPaymentRemoteDataSource {
  final IPaymentService _paymentService;

  PaymentRemoteDataSource(this._paymentService);

  @override
  Future<PaymentIntentEntity> createPaymentIntent({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
    String? couponCode,
  }) async {
    final res = await _paymentService.createPaymentIntent(
      ownerId: ownerId,
      planId: planId,
      subscriptionType: subscriptionType,
      paymentMethod: paymentMethod,
      walletNumber: walletNumber,
      couponCode: couponCode,
    );
    return PaymentIntentEntity(
      paymentUrl: res.paymentUrl,
      transactionId: res.transactionId,
      orderId: res.orderId,
      referenceNumber: res.referenceNumber,
      fawryCode: res.fawryCode,
      subscriptionId: res.subscriptionId,
      amount: res.amount,
      currency: res.currency,
    );
  }

  @override
  Future<PaymentStatusEntity> checkPaymentStatus(String transactionId) async {
    final res = await _paymentService.checkPaymentStatus(transactionId);
    return PaymentStatusEntity(
      transactionId: res.transactionId,
      referenceNumber: res.referenceNumber,
      gatewayOrderId: res.gatewayOrderId,
      fawryCode: res.fawryCode,
      status: res.status,
      paymentMethod: res.paymentMethod,
      amount: res.amount,
      currency: res.currency,
      errorMessage: res.errorMessage,
      subscriptionId: res.subscriptionId,
      subscriptionStatus: res.subscriptionStatus,
      subscriptionType: res.subscriptionType,
      planId: res.planId,
      startedAt: res.startedAt,
      endAt: res.endAt,
    );
  }
}

