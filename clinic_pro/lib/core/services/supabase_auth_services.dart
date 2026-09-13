import 'dart:async';
import 'dart:io';
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

  static HttpServer? _activeServer;

  @override
  Future<void> signInWithGoogle() async {
    // ────────────────────────────────────────────────────────
    // في بيئة سطح المكتب (Windows / Desktop): نستخدم OAuth عبر المتصفح
    // ────────────────────────────────────────────────────────
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // إغلاق أي سيرفر سابق قيد التشغيل لتجنب تعارض المنافذ
      try {
        await _activeServer?.close(force: true);
        _activeServer = null;
      } catch (_) {}

      // 1. فتح سيرفر محلي مؤقت يدعم Dual-Stack (IPv4 & IPv6) لاستقبال التوكن
      HttpServer server;
      try {
        server = await HttpServer.bind(InternetAddress.anyIPv6, 54321, v6Only: false);
      } catch (e) {
        debugPrint('⚠️ تعذر تشغيل dual-stack، جاري المحاولة عبر loopback IPv4: $e');
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 54321);
      }
      _activeServer = server;
      debugPrint('🌐 تم تشغيل السيرفر المحلي للمصادقة بنجاح على: http://localhost:54321');

      final completer = Completer<void>();

      // الاستماع للطلب القادم من المتصفح بعد إتمام جوجل للدخول
      server.listen((HttpRequest request) async {
        final uri = request.uri;
        debugPrint('📩 استلام طلب في السيرفر المحلي: ${request.method} ${uri.toString()}');

        // إرسال صفحة نجاح طبية احترافية للمتصفح
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..write('''
            <!DOCTYPE html>
            <html dir="rtl" lang="ar">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Clinic Pro — تم تسجيل الدخول بنجاح</title>
              <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body {
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", Tahoma, sans-serif;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  min-height: 100vh;
                  background: radial-gradient(circle at top, #092e42 0%, #001b27 60%, #000f17 100%);
                  color: #ffffff;
                  overflow: hidden;
                  position: relative;
                }
                
                /* خلفية نبضات القلب الطبية الخافتة */
                .ecg-bg {
                  position: absolute;
                  bottom: 10%;
                  left: 0;
                  width: 200%;
                  height: 120px;
                  opacity: 0.08;
                  pointer-events: none;
                  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 100" fill="none" stroke="%232ECC9A" stroke-width="2"><path d="M0,50 L200,50 L210,50 L220,10 L230,90 L240,40 L250,60 L260,50 L500,50 L700,50 L710,50 L720,10 L730,90 L740,40 L750,60 L760,50 L1000,50"/></svg>');
                  background-repeat: repeat-x;
                  background-size: 600px 100px;
                  animation: ecgScroll 18s linear infinite;
                }
                @keyframes ecgScroll {
                  0% { transform: translateX(0); }
                  100% { transform: translateX(-50%); }
                }

                .card {
                  position: relative;
                  z-index: 10;
                  background: rgba(14, 38, 55, 0.75);
                  backdrop-filter: blur(20px);
                  -webkit-backdrop-filter: blur(20px);
                  border: 1px solid rgba(46, 204, 154, 0.25);
                  padding: 44px 36px;
                  border-radius: 24px;
                  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.6), 0 0 40px rgba(46, 204, 154, 0.12);
                  max-width: 480px;
                  width: 90%;
                  text-align: center;
                  animation: cardFadeUp 0.6s cubic-bezier(0.16, 1, 0.3, 1);
                }
                @keyframes cardFadeUp {
                  from { opacity: 0; transform: translateY(24px) scale(0.96); }
                  to { opacity: 1; transform: translateY(0) scale(1); }
                }

                /* أيقونة الشعار الطبي مع الهالة */
                .icon-container {
                  position: relative;
                  width: 96px;
                  height: 96px;
                  margin: 0 auto 24px;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                }
                .icon-glow {
                  position: absolute;
                  inset: -6px;
                  border-radius: 50%;
                  background: conic-gradient(from 0deg, #2ECC9A, #00A3C4, #2ECC9A);
                  opacity: 0.7;
                  filter: blur(12px);
                  animation: pulseGlow 3s ease-in-out infinite;
                }
                @keyframes pulseGlow {
                  0%, 100% { opacity: 0.5; transform: scale(0.95); }
                  50% { opacity: 0.9; transform: scale(1.08); }
                }
                .icon-circle {
                  position: relative;
                  width: 88px;
                  height: 88px;
                  border-radius: 50%;
                  background: linear-gradient(135deg, #00526D 0%, #082d3f 100%);
                  border: 2px solid #2ECC9A;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4);
                }
                .icon-circle svg {
                  width: 48px;
                  height: 48px;
                  color: #2ECC9A;
                }

                /* الشارة الطبية */
                .medical-badge {
                  display: inline-flex;
                  align-items: center;
                  gap: 6px;
                  padding: 6px 14px;
                  border-radius: 20px;
                  background: rgba(46, 204, 154, 0.12);
                  border: 1px solid rgba(46, 204, 154, 0.3);
                  color: #2ECC9A;
                  font-size: 13px;
                  font-weight: 600;
                  margin-bottom: 16px;
                  letter-spacing: 0.3px;
                }

                h1 {
                  color: #ffffff;
                  font-size: 24px;
                  font-weight: 700;
                  margin-bottom: 10px;
                  line-height: 1.3;
                }
                .brand-title {
                  color: #38bdf8;
                  font-size: 14px;
                  text-transform: uppercase;
                  letter-spacing: 1.5px;
                  font-weight: 600;
                  margin-bottom: 16px;
                }

                p {
                  color: #94a3b8;
                  font-size: 15px;
                  line-height: 1.7;
                  margin-bottom: 26px;
                }
                .highlight {
                  color: #f1f5f9;
                  font-weight: 600;
                }

                /* صندوق الإرشاد */
                .instruction-box {
                  background: rgba(46, 204, 154, 0.08);
                  border: 1px dashed rgba(46, 204, 154, 0.35);
                  border-radius: 14px;
                  padding: 14px 20px;
                  font-size: 14px;
                  color: #cbd5e1;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  gap: 10px;
                  margin-top: 12px;
                }

                .footer-text {
                  margin-top: 24px;
                  font-size: 12px;
                  color: #64748b;
                }
              </style>
            </head>
            <body>
              <div class="ecg-bg"></div>

              <div class="card">
                <!-- أيقونة طبية متألقة -->
                <div class="icon-container">
                  <div class="icon-glow"></div>
                  <div class="icon-circle">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
                      <circle cx="12" cy="12" r="2" fill="%232ECC9A" stroke="none" />
                    </svg>
                  </div>
                </div>

                <div class="medical-badge">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    <path d="m9 12 2 2 4-4"/>
                  </svg>
                  توثيق طبي آمن ومشفّر
                </div>

                <div class="brand-title">Clinic Pro • Medical System</div>
                <h1>تم التحقق وتسجيل الدخول بنجاح!</h1>
                <p>تم تأكيد هويتك الطبية بنجاح.<br>يمكنك الآن <span class="highlight">العودة إلى التطبيق</span> ومتابعة إدارة عيادتك بكل سلاسة.</p>

                <div class="instruction-box">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2ECC9A" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                  </svg>
                  <span>يمكنك إغلاق هذا التبويب بأمان والعودة لبرنامج Clinic Pro</span>
                </div>

                <div class="footer-text">نظام Clinic Pro • رعاية صحية أذكى وأكثر دقة</div>
              </div>

              <script>
                // إعادة توجيه الـ hash parameters إن وجدت (في حالة Implicit flow)
                if (window.location.hash) {
                  window.location.href = '/callback?' + window.location.hash.substring(1);
                }
              </script>
            </body>
            </html>
          ''');
        await request.response.close();

        // تمرير الرابط كاملاً لـ Supabase لاستخراج الجلسة
        try {
          final fullUri = Uri.parse('http://localhost:54321${uri.toString()}');
          if (fullUri.queryParameters.containsKey('code') || fullUri.queryParameters.containsKey('access_token')) {
            debugPrint('🔑 جاري استخراج وتثبيت الجلسة من Supabase: $fullUri');
            await supabase.auth.getSessionFromUrl(fullUri);
            debugPrint('✅ تم حفظ جلسة المستخدم بنجاح!');
            if (!completer.isCompleted) completer.complete();
          }
        } catch (e) {
          debugPrint('⚠️ خطأ في معالجة جلسة Supabase: $e');
        }
      });

      // 2. إطلاق المتصفح وتوجيهه للسيرفر المحلي
      final success = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:54321/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!success) {
        await server.close(force: true);
        if (_activeServer == server) _activeServer = null;
        throw Exception('فشل فتح متصفح تسجيل الدخول.');
      }

      // 3. انتظار عودة المستخدم أو انتهاء المهلة ثم إغلاق السيرفر بنعومة
      try {
        await completer.future.timeout(const Duration(minutes: 2));
      } finally {
        await Future.delayed(const Duration(milliseconds: 500));
        await server.close(force: true);
        if (_activeServer == server) _activeServer = null;
        debugPrint('🛑 تم إيقاف السيرفر المحلي للمصادقة.');
      }
      return;
    }

    // ────────────────────────────────────────────────────────
    // في بيئة الهواتف (Android / iOS): نستخدم Google SDK المدمج
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
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'clinicpro://reset-password',
    );
  }

  @override
  Future<void> updatePassword(String password) {
    return supabase.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> sendInvitation(Map<String, dynamic> metadata) async {
    final res = await supabase.functions.invoke(
      'invite_staff',
      body: metadata,
    );

    if (res.status != 200) {
      throw Exception(res.data);
    }
  }

  @override
  Future<void> deleteUserFromAuth(String userId) async {
    try {
      final res = await supabase.functions.invoke(
        'delete_user',
        body: {'user_id': userId},
      );

      debugPrint("Delete Status: ${res.status}");
      debugPrint("Delete Data: ${res.data}");

      if (res.status != 200) {
        throw Exception(res.data);
      }

      debugPrint("User deleted from Auth successfully");
    } catch (e, stackTrace) {
      debugPrint("Error deleting user: $e");
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
