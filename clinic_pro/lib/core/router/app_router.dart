import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

import '../../features/auth/presentation/ui/splash_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/create_account_screen.dart';
import '../../features/auth/presentation/ui/accept_invitation_screen.dart';
import '../../features/onboarding/presentation/ui/plan_screen.dart';
import '../../features/onboarding/presentation/ui/create_clinic_screen.dart';
import '../../features/onboarding/presentation/ui/invite_staff_screen.dart';

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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteConstants.register,
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: RouteConstants.joinClinic,
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return AcceptInvitationScreen(token: token);
      },
    ),
    GoRoute(
      path: RouteConstants.onboardingPlan,
      builder: (context, state) => const PlanScreen(),
    ),
    GoRoute(
      path: RouteConstants.onboardingClinic,
      builder: (context, state) => const CreateClinicScreen(),
    ),
    GoRoute(
      path: RouteConstants.onboardingInvite,
      builder: (context, state) => const InviteStaffScreen(),
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
  ],
);
