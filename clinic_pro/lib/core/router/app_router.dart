import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';

import '../../features/auth/presentation/ui/splash_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/create_account_screen.dart';
import '../../features/auth/presentation/ui/accept_invitation_screen.dart';
import '../../features/onboarding/presentation/ui/plan_screen.dart';
import '../../features/clinics/presentation/ui/create_clinic_screen.dart';
import '../../features/staff/presentation/ui/invite_staff_screen.dart';
import '../../features/dashboard/presentation/ui/owner_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/doctor_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/secretary_dashboard_screen.dart';
import '../../features/appointments/presentation/ui/appointments_screen.dart';
import '../../features/appointments/presentation/ui/appointment_details_screen.dart';
import '../../features/appointments/presentation/ui/waiting_queue_screen.dart';
import '../../features/patients/presentation/ui/patients_screen.dart';
import '../../features/patients/presentation/ui/patient_details_screen.dart';
import '../../features/prescription/presentation/ui/drugs_screen.dart';
import '../../features/prescription/presentation/ui/prescription_screen.dart';
import '../../features/prescription/presentation/ui/templates_screen.dart';
import '../../features/settings/presentation/ui/settings_screen.dart';
import '../../features/settings/presentation/ui/subscription_screen.dart';
import '../../features/staff/presentation/ui/staff_screen.dart';
import '../../features/clinics/presentation/ui/clinics_screen.dart';
import '../../features/clinics/presentation/ui/clinic_details_screen.dart';
import '../../features/invoices/presentation/ui/invoices_screen.dart';
import '../../features/expenses/presentation/ui/expenses_screen.dart';
import '../../features/reports/presentation/ui/reports_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => LoginScreen(),
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isOnboarding = extra?['isOnboarding'] as bool? ?? true;
        return InviteStaffScreen(isOnboarding: isOnboarding);
      },
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
    GoRoute(
      path: RouteConstants.patients,
      builder: (context, state) => const PatientsScreen(),
    ),
    GoRoute(
      path: RouteConstants.patientDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PatientDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: RouteConstants.prescriptionNew,
      builder: (context, state) {
        final appointmentId = state.pathParameters['appointment_id'] ?? '';
        return PrescriptionScreen(appointmentId: appointmentId);
      },
    ),
    GoRoute(
      path: RouteConstants.prescriptionEdit,
      builder: (context, state) {
        final appointmentId = state.pathParameters['appointment_id'] ?? '';
        return PrescriptionScreen(
          appointmentId: appointmentId,
          isEditing: true,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.prescriptionTemplates,
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      path: RouteConstants.drugs,
      builder: (context, state) => const DrugsScreen(),
    ),
    GoRoute(
      path: RouteConstants.staff,
      builder: (context, state) => const StaffScreen(),
    ),
    GoRoute(
      path: RouteConstants.clinics,
      builder: (context, state) => const ClinicsScreen(),
    ),
    GoRoute(
      path: RouteConstants.clinicDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ClinicDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: RouteConstants.settings,
      builder: (context, state) => const SettingsScreen(showBottomNav: true),
    ),
    GoRoute(
      path: RouteConstants.settingsSubscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: RouteConstants.invoices,
      builder: (context, state) => const InvoicesScreen(),
    ),
    GoRoute(
      path: RouteConstants.expenses,
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: RouteConstants.reports,
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);
