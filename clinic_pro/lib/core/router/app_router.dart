import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

import '../../features/auth/presentation/ui/splash_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/create_account_screen.dart';
import '../../features/auth/presentation/ui/accept_invitation_screen.dart';
import '../../features/onboarding/presentation/ui/plan_screen.dart';
import '../../features/onboarding/presentation/ui/create_clinic_screen.dart';
import '../../features/onboarding/presentation/ui/invite_staff_screen.dart';
import '../../features/dashboard/presentation/ui/owner_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/doctor_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/secretary_dashboard_screen.dart';
import '../../features/appointments/presentation/ui/appointments_screen.dart';
import '../../features/appointments/presentation/ui/appointment_details_screen.dart';
import '../../features/appointments/presentation/ui/waiting_queue_screen.dart';

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
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: RouteConstants.doctorDashboard,
      builder: (context, state) => const DoctorDashboardScreen(),
    ),
    GoRoute(
      path: RouteConstants.secretaryDashboard,
      builder: (context, state) => const SecretaryDashboardScreen(),
    ),
    GoRoute(
      path: RouteConstants.appointments,
      builder: (context, state) => const AppointmentsScreen(),
    ),
    GoRoute(
      path: RouteConstants.appointmentDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AppointmentDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: RouteConstants.waitingQueue,
      builder: (context, state) => const WaitingQueueScreen(),
    ),
  ],
);
