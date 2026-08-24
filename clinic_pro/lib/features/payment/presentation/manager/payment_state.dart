// ────────────────────────────────────────────────────────
// حالات الدفع (PaymentState)
// ────────────────────────────────────────────────────────

import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../domain/entities/payment_intent_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status_entity.dart';


abstract class PaymentState {
  const PaymentState();
}

/// الحالة الأولية
class PaymentInitial extends PaymentState {}

/// جاري إنشاء عملية الدفع على السيرفر
class PaymentCreatingIntent extends PaymentState {}

/// رابط صفحة الدفع جاهز → يفتح WebView
class PaymentIntentReady extends PaymentState {
  final PaymentIntentEntity intentResult;
  final PlanEntity plan;
  final String subscriptionType;
  final PaymentMethod paymentMethod;

  const PaymentIntentReady({
    required this.intentResult,
    required this.plan,
    required this.subscriptionType,
    required this.paymentMethod,
  });
}

/// جاري التحقق من نتيجة الدفع (بعد إغلاق WebView)
class PaymentVerifying extends PaymentState {}

/// الدفع تم بنجاح والاشتراك مُفعّل
class PaymentSuccess extends PaymentState {
  final PaymentStatusEntity statusResult;
  final PlanEntity plan;
  final String subscriptionType;

  const PaymentSuccess({
    required this.statusResult,
    required this.plan,
    required this.subscriptionType,
  });
}


/// الدفع فشل
class PaymentFailed extends PaymentState {
  final String message;
  final PlanEntity? plan;
  final String? subscriptionType;
  final PaymentMethod? paymentMethod;

  const PaymentFailed({
    required this.message,
    this.plan,
    this.subscriptionType,
    this.paymentMethod,
  });
}

/// المستخدم ألغى الدفع
class PaymentCancelled extends PaymentState {}

/// خطأ عام
class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}
