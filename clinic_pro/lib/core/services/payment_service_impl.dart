// ────────────────────────────────────────────────────────
// تنفيذ خدمة الدفع السحابية بواسطة Supabase Edge Functions & Paymob
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../features/payment/data/models/payment_intent_model.dart';
import '../../features/payment/data/models/payment_status_model.dart';
import '../../features/payment/domain/entities/payment_intent_entity.dart';
import '../../features/payment/domain/entities/payment_method.dart';
import '../../features/payment/domain/entities/payment_status_entity.dart';
import '../strings/app_strings.dart';
import 'i_cloud_service.dart';
import 'i_payment_service.dart';

@LazySingleton(as: IPaymentService)
class PaymentServiceImpl implements IPaymentService {
  final ICloudService _cloudService;

  PaymentServiceImpl(this._cloudService);

  @override
  Future<PaymentIntentEntity> createPaymentIntent({
    required String ownerId,
    required String planId,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
  }) async {
    final response = await _cloudService.invokeFunction(
      'create_payment_intent',
      body: {
        'owner_id': ownerId,
        'plan_id': planId,
        'subscription_type': subscriptionType,
        'payment_method': paymentMethod.value,
        if (walletNumber != null && walletNumber.isNotEmpty) 'wallet_number': walletNumber,
      },
    );

    if (response == null) {
      throw Exception(AppStrings.paymentServiceEmptyResponse);
    }

    final data = Map<String, dynamic>.from(response as Map);

    if (data.containsKey('error')) {
      throw Exception(data['error'] ?? AppStrings.unknownPaymentError);
    }

    return PaymentIntentModel.fromJson(data);

  }

  @override
  Future<PaymentStatusEntity> checkPaymentStatus(String transactionId) async {
    final response = await _cloudService.rpc(
      'get_payment_status',
      params: {'p_transaction_id': transactionId},
    );

    if (response == null) {
      throw Exception(AppStrings.transactionStatusQueryError);
    }

    final data = Map<String, dynamic>.from(
      (response is List && response.isNotEmpty)
          ? response.first as Map
          : response as Map,
    );

    return PaymentStatusModel.fromJson(data);
  }
}
