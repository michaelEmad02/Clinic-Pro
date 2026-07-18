// ────────────────────────────────────────────────────────
// تعريف الأخطاء العامة للتطبيق (Failures)
// ────────────────────────────────────────────────────────

abstract class Failure {
  final String message;
  const Failure(this.message);
}

