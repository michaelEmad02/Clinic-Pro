// ────────────────────────────────────────────────────────
// إدارة حالات الدفع (PaymentCubit)
// Cubit مستقل عن SubscriptionsCubit — يدير عملية الدفع فقط
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/usecases/payment_usecases.dart';
import 'payment_state.dart';


@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final CreatePaymentIntentUseCase _createPaymentIntentUseCase;
  final CheckPaymentStatusUseCase _checkPaymentStatusUseCase;

  // تخزين بيانات العملية الحالية للاستخدام عند إعادة المحاولة
  PlanEntity? _currentPlan;
  String? _currentSubscriptionType;
  PaymentMethod? _currentPaymentMethod;

  PaymentCubit({
    required CreatePaymentIntentUseCase createPaymentIntentUseCase,
    required CheckPaymentStatusUseCase checkPaymentStatusUseCase,
  })  : _createPaymentIntentUseCase = createPaymentIntentUseCase,
        _checkPaymentStatusUseCase = checkPaymentStatusUseCase,
        super(PaymentInitial());

  /// بدء عملية الدفع — يستدعي Edge Function لإنشاء payment intent
  Future<void> initiatePayment({
    required String ownerId,
    required PlanEntity plan,
    required String subscriptionType,
    required PaymentMethod paymentMethod,
    String? walletNumber,
  }) async {
    try {
      _currentPlan = plan;
      _currentSubscriptionType = subscriptionType;
      _currentPaymentMethod = paymentMethod;

      emit(PaymentCreatingIntent());

      final result = await _createPaymentIntentUseCase(
        ownerId: ownerId,
        planId: plan.id,
        subscriptionType: subscriptionType,
        paymentMethod: paymentMethod,
        walletNumber: walletNumber,
      );

      result.fold(
        (failure) => emit(PaymentFailed(
          message: failure.message,
          plan: plan,
          subscriptionType: subscriptionType,
          paymentMethod: paymentMethod,
        )),
        (intentResult) {
          emit(PaymentIntentReady(
            intentResult: intentResult,
            plan: plan,
            subscriptionType: subscriptionType,
            paymentMethod: paymentMethod,
          ));
        },
      );
    } catch (e) {
      emit(PaymentFailed(
        message: AppStrings.paymentInitiationError,
        plan: plan,
        subscriptionType: subscriptionType,
        paymentMethod: paymentMethod,
      ));
    }
  }

  /// التحقق من حالة الدفع بعد إغلاق WebView
  /// يقوم بـ polling حتى تتغير الحالة من pending
  Future<void> verifyPayment({
    required String transactionId,
    required PlanEntity plan,
    required String subscriptionType,
  }) async {
    try {
      _currentPlan = plan;
      _currentSubscriptionType = subscriptionType;
      emit(PaymentVerifying());

      const maxAttempts = 10;
      const delaySeconds = 3;

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final result = await _checkPaymentStatusUseCase(transactionId);

        final shouldStop = result.fold(
          (failure) {
            emit(PaymentFailed(
              message: failure.message,
              plan: _currentPlan,
              subscriptionType: _currentSubscriptionType,
              paymentMethod: _currentPaymentMethod,
            ));
            return true;
          },
          (statusResult) {
            if (statusResult.isSuccess) {
              emit(PaymentSuccess(
                statusResult: statusResult,
                plan: plan,
                subscriptionType: subscriptionType,
              ));
              return true;
            }
            if (statusResult.isFailed) {
              emit(PaymentFailed(
                message: statusResult.errorMessage ?? AppStrings.paymentFailedDefault,
                plan: _currentPlan,
                subscriptionType: _currentSubscriptionType,
                paymentMethod: _currentPaymentMethod,
              ));
              return true;
            }
            // لا تزال pending → نعيد المحاولة
            return false;
          },
        );

        if (shouldStop) return;

        // انتظار قبل المحاولة التالية
        await Future.delayed(const Duration(seconds: delaySeconds));
      }

      // وصلنا لأقصى عدد محاولات ولا تزال pending
      emit(PaymentFailed(
        message: AppStrings.paymentConfirmationTimeout,
        plan: _currentPlan,
        subscriptionType: _currentSubscriptionType,
        paymentMethod: _currentPaymentMethod,
      ));
    } catch (e) {
      emit(PaymentFailed(
        message: AppStrings.paymentVerificationError,
        plan: plan,
        subscriptionType: subscriptionType,
        paymentMethod: _currentPaymentMethod,
      ));
    }
  }

  /// إلغاء الدفع من المستخدم (أغلق WebView قبل الدفع)
  void cancelPayment() {
    emit(PaymentCancelled());
  }

  /// إعادة تعيين الحالة
  void reset() {
    emit(PaymentInitial());
  }
}
