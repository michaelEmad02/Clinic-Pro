// ────────────────────────────────────────────────────────
// تعريف الأخطاء العامة للتطبيق (Failures)
// ────────────────────────────────────────────────────────

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة وإعادة المحاولة']);
}



