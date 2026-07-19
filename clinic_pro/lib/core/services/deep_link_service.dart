// ────────────────────────────────────────────────────────
// خدمة التعامل مع الروابط العميقة (Deep Links)
// تستمع لروابط الدعوة الواردة وتوجه لشاشة قبول الدعوة
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final GoRouter _router;
  StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this._router);

  /// تهيئة الخدمة — تُستدعى مرة واحدة عند بدء التطبيق
  Future<void> init() async {
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
  }

  /// إيقاف الاستماع عند إنهاء التطبيق
  void dispose() {
    _linkSubscription?.cancel();
  }
}
