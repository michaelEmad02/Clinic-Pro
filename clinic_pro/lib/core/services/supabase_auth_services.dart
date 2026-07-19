import 'package:clinic_pro/core/services/i_auth_services.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

@LazySingleton(as: IAuthServices)
class SupabaseAuthServices extends IAuthServices {
  final SupabaseClient supabase;

  SupabaseAuthServices(this.supabase);
  @override
  Future<String?> getCurrentUserEmail() async {
    return supabase.auth.currentUser?.email ?? "";
  }

  @override
  Future<String?> getCurrentUserName() async {
    // جلب الاسم الكامل من البيانات التعريفية المرجعة من مزود الخدمة (مثل جوجل)
    final metadata = supabase.auth.currentUser?.userMetadata;
    return metadata?['full_name'] as String? ?? metadata?['name'] as String?;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return supabase.auth.currentUser?.id ?? "";
  }

  @override
  Future<bool> isEmailVerified(String email) async {
    return supabase.auth.currentUser?.emailConfirmedAt != null;
  }

  @override
  Future<void> signUp(
      String email, String password, String phone, String country) async {
    await supabase.auth.signUp(email: email, password: password);
    await supabase.auth
        .resend(type: OtpType.signup, email: email); // send verfication mail
  }

  @override
  Future<void> sendMagicLink(String email) async {
    return await supabase.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    // ────────────────────────────────────────────────────────
    // تسجيل دخول محلي باستخدام Google SDK داخل الهاتف
    // ────────────────────────────────────────────────────────

    // 1. تهيئة مكامل تسجيل الدخول بجوجل
    // ملاحظة: الـ webClientId مطلوب لـ Supabase للتحقق من هوية الـ ID Token
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId:
          '403194501930-ikd9bkqd8nsqllo1fkvj1lclcj3cteug.apps.googleusercontent.com', // يتم استبداله بالـ Web Client ID المعتمد من جوجل عند الرفع
    );

    // 2. فتح نافذة اختيار الحسابات الرسمية
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // ألغى المستخدم العملية
      throw Exception('تم إلغاء عملية تسجيل الدخول بواسطة المستخدم.');
    }

    // 3. جلب الـ Tokens للمصادقة
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('فشل الحصول على رمز الهوية (ID Token) من جوجل.');
    }

    // 4. إرسال الـ Tokens إلى Supabase لتوثيق الجلسة
    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // نتجنب حدوث أخطاء إذا لم يكن مسجلاً بجوجل أصلاً
    }
  }

  @override
  Future<void> verifyEmail(String email, String token) {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String email, String password) {
    return supabase.auth
        .updateUser(UserAttributes(email: email, password: password));
  }

  @override
  Future<void> sendInvitation(Map<String, dynamic> metadata) async {
    try {
      final res = await supabase.functions.invoke(
        'invite_staff',
        body: metadata,
      );

      debugPrint("Status: ${res.status}");
      debugPrint("Data: ${res.data}");

      if (res.status != 200) {
        throw Exception(res.data);
      }

      print("Invitation sent successfully");
    } catch (e, stackTrace) {
      debugPrint("Error: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
