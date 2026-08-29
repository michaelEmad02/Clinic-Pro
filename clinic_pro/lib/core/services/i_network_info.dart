// ────────────────────────────────────────────────────────
// واجهة التحقق من حالة الاتصال بالإنترنت (INetworkInfo)
// تتبع مبادئ Clean Architecture
// ────────────────────────────────────────────────────────

abstract class INetworkInfo {
  /// التحقق السريع من وجود اتصال إنترنت فعلي نشط
  Future<bool> get isConnected;

  /// بث حي (Stream) للتغيرات في حالة اتصال الإنترنت
  Stream<bool> get onConnectivityChanged;
}
