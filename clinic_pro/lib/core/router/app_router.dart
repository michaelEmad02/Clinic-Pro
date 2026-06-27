import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

// دالة مساعدة لإنشاء شاشات مؤقتة (Placeholders)
Widget _buildPlaceholder(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('شاشة $title قيد التطوير')),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      builder: (context, state) => _buildPlaceholder('سبلاش'),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => _buildPlaceholder('تسجيل الدخول'),
    ),
    GoRoute(
      path: RouteConstants.register,
      builder: (context, state) => _buildPlaceholder('إنشاء حساب'),
    ),
    GoRoute(
      path: RouteConstants.ownerDashboard,
      builder: (context, state) => _buildPlaceholder('لوحة تحكم المالك'),
    ),
    GoRoute(
      path: RouteConstants.doctorDashboard,
      builder: (context, state) => _buildPlaceholder('لوحة تحكم الطبيب'),
    ),
    GoRoute(
      path: RouteConstants.secretaryDashboard,
      builder: (context, state) => _buildPlaceholder('لوحة تحكم السكرتارية'),
    ),
    // أضف باقي المسارات هنا مع تقدم المشروع
  ],
);
