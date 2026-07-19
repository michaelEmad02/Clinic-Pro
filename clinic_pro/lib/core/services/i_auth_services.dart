// ────────────────────────────────────────────────────────
// واجهة الخدمات المتعلقة بالمصادقة (IAuthServices)
// تفصل طبقة البيانات عن تفاصيل Supabase Auth أو خدمات المحاكاة
// ────────────────────────────────────────────────────────

abstract class IAuthServices {
  /// جلب معرف المستخدم الحالي المسجل دخوله
  Future<String?> getCurrentUserId();

  /// جلب البريد الإلكتروني للمستخدم الحالي
  Future<String?> getCurrentUserEmail();

  /// جلب الاسم الكامل للمستخدم الحالي (من بيانات Google/Apple)
  Future<String?> getCurrentUserName();

  Future<void> signUp(
      String email, String password, String phone, String country);

  /// تسجيل الدخول عبر Google
  Future<void> signInWithGoogle();

  /// تسجيل الدخول عبر Apple
  Future<void> signInWithApple();

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// إرسال رابط الدخول السحري
  Future<void> sendMagicLink(String email);

  /// التحقق من البريد الإلكتروني (عبر كود OTP أو رمز تفعيل)
  Future<void> verifyEmail(String email, String token);

  /// التحقق مما إذا كان البريد الإلكتروني مفعلاً
  Future<bool> isEmailVerified(String email);

  Future<void> resetPassword(String email);

  Future<void> updatePassword(String email, String password);

  /// تسجيل الخروج
  Future<void> signOut();

  Future<void> sendInvitation(Map<String, dynamic> metadata);

  /// حذف حساب مستخدم نهائياً من الـ Auth عبر Edge Function
  Future<void> deleteUserFromAuth(String userId);
}
