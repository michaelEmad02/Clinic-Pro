// ────────────────────────────────────────────────────────
// فئة تهيئة خدمات التطبيق عند الإقلاع (AppInitializer)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/injection_container.dart';
import '../router/app_router.dart';
import '../utils/app_bloc_observer.dart';
import 'deep_link_service.dart';

class AppInitializer {
  /// دالة التهيئة المركزية لجميع الخدمات عند بدء التطبيق
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // تهيئة مراقب الـ Bloc
    Bloc.observer = AppBlocObserver();

    // 1. تهئية Supabase سحابياً
    await Supabase.initialize(
      url: "https://sybsvobonipnmvymauvc.supabase.co",
      publishableKey: "sb_publishable_PHmN-KnBgnhDYISy7wBNPA_U4mfPLba",
    );

    // 2. تهيئة حقن الاعتماديات (Dependency Injection)
    await configureDependencies();
    await sl.allReady();

    // 3. تهيئة خدمة الروابط العميقة (Deep Links) لالتقاط روابط الدعوات
    final deepLinkService = DeepLinkService(appRouter);
    await deepLinkService.init();
  }
}
