import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/route_constants.dart';
import '../di/injection_container.dart';
import '../../features/appointments/presentation/manager/appointments_bloc.dart';
import '../../features/appointments/presentation/manager/appointments_event.dart';

import '../../features/appointments/domain/entities/appointment_entity.dart';
import '../../features/auth/presentation/ui/splash_screen.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/create_account_screen.dart';
import '../../features/auth/presentation/ui/forgot_password_screen.dart';
import '../../features/auth/presentation/ui/set_new_password_screen.dart';
import '../../features/auth/presentation/ui/accept_invitation_screen.dart';
import '../../features/clinics/presentation/ui/create_clinic_screen.dart';
import '../../features/staff_and_invitations/presentation/ui/invite_staff_screen.dart';
import '../../features/dashboard/presentation/ui/owner_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/doctor_dashboard_screen.dart';
import '../../features/dashboard/presentation/ui/secretary_dashboard_screen.dart';
import '../../features/appointments/presentation/ui/appointments_screen.dart';
import '../../features/appointments/presentation/ui/appointment_details_screen.dart';
import '../../features/appointments/presentation/ui/waiting_queue_screen.dart';
import '../../features/patients/presentation/ui/patients_screen.dart';
import '../../features/patients/presentation/ui/patient_details_screen.dart';
import '../../features/prescription/presentation/ui/all_prescriptions_screen.dart';
import '../../features/prescription/presentation/ui/drugs_screen.dart';
import '../../features/prescription/presentation/ui/prescription_screen.dart';
import '../../features/prescription/presentation/ui/templates_screen.dart';
import '../../features/settings/presentation/ui/settings_screen.dart';
import '../../features/settings/presentation/ui/about_us_screen.dart';
import '../../features/plans_and_subscriptions/domain/entities/company_info_entity.dart';
import '../../features/plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../features/plans_and_subscriptions/presentation/ui/subscription_screen.dart';
import '../../features/plans_and_subscriptions/presentation/ui/plans_comparison_screen.dart';
import '../../features/plans_and_subscriptions/presentation/ui/pending_subscription_screen.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/ui/enter_referral_code_screen.dart';
import 'package:clinic_pro/features/payment/presentation/ui/payment_methods_screen.dart';
import '../../features/payment/presentation/ui/payment_webview_screen.dart';
import '../../features/payment/presentation/ui/payment_success_screen.dart';
import '../../features/payment/presentation/ui/payment_failed_screen.dart';
import '../../features/payment/domain/entities/payment_status_entity.dart';



import '../../features/staff_and_invitations/presentation/ui/staff_screen.dart';
import '../../features/clinics/presentation/ui/clinics_screen.dart';
import '../../features/clinics/presentation/ui/clinic_details_screen.dart';
import '../../features/invoices/presentation/ui/invoices_screen.dart';
import '../../features/expenses/presentation/ui/expenses_screen.dart';
import '../../features/owner_referrals/presentation/ui/referral_dashboard_screen.dart';
import '../../features/reports/presentation/ui/reports_screen.dart';
import '../../features/reports/presentation/ui/financial_receivables_screen.dart';
import '../../features/reports/presentation/ui/doctor_my_reports_screen.dart';

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
      path: RouteConstants.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteConstants.resetPassword,
      builder: (context, state) => const SetNewPasswordScreen(),
    ),
    GoRoute(
      path: RouteConstants.joinClinic,
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return AcceptInvitationScreen(token: token);
      },
    ),
    GoRoute(
      path: RouteConstants.onboardingReferral,
      builder: (context, state) => const EnterReferralCodeScreen(),
    ),
    GoRoute(
      path: RouteConstants.onboardingPlan,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialCouponCode = extra?['initialCouponCode'] as String?;
        return PlansComparisonScreen(
          isOnboarding: true,
          initialCouponCode: initialCouponCode,
        );
      },
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
        return BlocProvider(
          create: (context) => sl<AppointmentsBloc>()..add(GetAppointmentDetailsEvent(id)),
          child: AppointmentDetailsScreen(id: id),
        );
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
        final extraAppt = state.extra as AppointmentEntity?;
        final appointment = extraAppt ??
            AppointmentEntity(
              id: appointmentId,
              clinicId: '',
              doctorId: '',
              patientId: '',
              typeId: '',
              date: DateTime.now().toIso8601String().substring(0, 10),
              status: 'in_progress',
              price: 0,
              isUrgent: false,
              createdBy: '',
              createdAt: DateTime.now(),
            );
        return PrescriptionScreen(appointment: appointment);
      },
    ),
    GoRoute(
      path: RouteConstants.prescriptionEdit,
      builder: (context, state) {
        final appointmentId = state.pathParameters['appointment_id'] ?? '';
        final extraAppt = state.extra as AppointmentEntity?;
        final appointment = extraAppt ??
            AppointmentEntity(
              id: appointmentId,
              clinicId: '',
              doctorId: '',
              patientId: '',
              typeId: '',
              date: DateTime.now().toIso8601String().substring(0, 10),
              status: 'in_progress',
              price: 0,
              isUrgent: false,
              createdBy: '',
              createdAt: DateTime.now(),
            );
        return PrescriptionScreen(
          appointment: appointment,
          isEditing: true,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.allPrescriptions,
      builder: (context, state) => const AllPrescriptionsScreen(),
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
      path: RouteConstants.aboutUs,
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: RouteConstants.plansComparison,
      builder: (context, state) => const PlansComparisonScreen(),
    ),
    GoRoute(
      path: RouteConstants.pendingSubscription,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PendingSubscriptionScreen(
          plan: extra?['plan'] as PlanEntity?,
          subscriptionType: extra?['subscriptionType'] as String?,
          companyInfo: extra?['companyInfo'] as CompanyInfoEntity?,
          isExpired: extra?['isExpired'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.paymentMethods,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentMethodsScreen(
          targetPlan: extra!['targetPlan'] as PlanEntity,
          subscriptionType: extra['subscriptionType'] as String,
          companyInfo: extra['companyInfo'] as CompanyInfoEntity?,
          initialCouponCode: extra['initialCouponCode'] as String?,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.paymentWebview,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentWebviewScreen(
          paymentUrl: extra!['paymentUrl'] as String,
          transactionId: extra['transactionId'] as String,
          plan: extra['plan'] as PlanEntity,
          subscriptionType: extra['subscriptionType'] as String,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.paymentSuccess,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentSuccessScreen(
          statusResult: extra!['statusResult'] as PaymentStatusEntity,
          plan: extra['plan'] as PlanEntity,
          subscriptionType: extra['subscriptionType'] as String,
        );
      },
    ),

    GoRoute(
      path: RouteConstants.paymentFailed,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentFailedScreen(
          message: extra?['message'] as String? ?? '',
          plan: extra?['plan'] as PlanEntity?,
          subscriptionType: extra?['subscriptionType'] as String?,
          companyInfo: extra?['companyInfo'] as CompanyInfoEntity?,
        );
      },
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
    GoRoute(
      path: RouteConstants.reportsReceivables,
      builder: (context, state) => const FinancialReceivablesScreen(),
    ),
    GoRoute(
      path: RouteConstants.doctorMyReports,
      builder: (context, state) => const DoctorMyReportsScreen(),
    ),
    GoRoute(
      path: RouteConstants.referralDashboard,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final ownerId = extra?['ownerId'] as String? ?? '';
        return ReferralDashboardScreen(ownerId: ownerId);
      },
    ),
  ],
);
