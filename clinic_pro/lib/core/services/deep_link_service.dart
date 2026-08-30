// ────────────────────────────────────────────────────────
// خدمة التعامل مع الروابط العميقة (Deep Links)
// تستمع لروابط الدعوة الواردة وتوجه لشاشة قبول الدعوة
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final GoRouter _router;
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  DeepLinkService(this._router);

  /// تهيئة الخدمة — تُستدعى مرة واحدة عند بدء التطبيق
  Future<void> init() async {
    // 0. الاستماع لأحداث استعادة كلمة المرور من Supabase Auth مباشرة
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔐 تم استقبال حدث passwordRecovery من Supabase!');
        _router.go('/reset-password');
      }
    });

    // 1. التحقق من وجود رابط عميق فتح التطبيق (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Deep Link (cold start): $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('⚠️ خطأ في جلب الرابط الأولي: $e');
    }

    // 2. الاستماع للروابط الواردة أثناء عمل التطبيق (warm start)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('🔗 Deep Link (warm start): $uri');
        _handleDeepLink(uri);
      },
      onError: (error) {
        debugPrint('⚠️ خطأ في الاستماع للروابط: $error');
      },
    );
  }

  /// معالجة الرابط العميق الوارد واستخراج التوكن
  void _handleDeepLink(Uri uri) {
    // تجاهل روابط تسجيل الدخول الخاصة بـ Supabase لأن الحزمة تعالجها تلقائياً
    if (uri.host == 'login-callback') {
      return;
    }
    // الصيغة المتوقعة: clinicpro://join/{token}
    if (uri.scheme == 'clinicpro' && uri.host == 'join') {
      // استخراج التوكن من المسار
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final token = pathSegments.first;
        debugPrint('🎫 توكن الدعوة: $token');
        _router.go('/join/$token');
      }
    }

    // الصيغة المتوقعة: clinicpro://reset-password
    if (uri.scheme == 'clinicpro' && (uri.host == 'reset-password' || uri.path.contains('reset-password'))) {
      debugPrint('🔐 رابط استعادة كلمة المرور');
      
      // استخراج الـ code أو tokens إن وجدت في الرابط وتثبيت الجلسة
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        Supabase.instance.client.auth.exchangeCodeForSession(code).then((_) {
          _router.go('/reset-password');
        }).catchError((e) {
          debugPrint('⚠️ خطأ في إنشاء جلسة استعادة كلمة المرور: $e');
          _router.go('/reset-password');
        });
      } else {
        _router.go('/reset-password');
      }
    }
  }

  /// إيقاف الاستماع عند إنهاء التطبيق
  void dispose() {
    _linkSubscription?.cancel();
    _authSubscription?.cancel();
  }
}
