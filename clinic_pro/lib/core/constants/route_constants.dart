// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على جميع ثوابت مسارات التنقل (Route Paths)
// المستخدمة في إعداد GoRouter
// ────────────────────────────────────────────────────────

class RouteConstants {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String joinClinic = '/join/:token';

  // مسارات التهيئة والاشتراك (Onboarding)
  static const String onboardingAccount = '/onboarding/account';
  static const String onboardingPlan = '/onboarding/plan';
  static const String onboardingClinic = '/onboarding/clinic';
  static const String onboardingInvite = '/onboarding/invite';

  // لوحات التحكم للأدوار المختلفة
  static const String ownerDashboard = '/owner/dashboard';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String secretaryDashboard = '/secretary/dashboard';

  // إدارة المواعيد وقائمة الانتظار
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointments/:id';
  static const String waitingQueue = '/queue';

  // إدارة المرضى
  static const String patients = '/patients';
  static const String patientDetails = '/patients/:id';

  // الكشف الطبي والروشتات والأدوية
  static const String prescriptionNew = '/prescription/:appointment_id';
  static const String prescriptionEdit = '/prescription/edit/:appointment_id';
  static const String prescriptionTemplates = '/templates';
  static const String drugs = '/drugs';

  // الإدارة المالية والتقارير
  static const String invoices = '/invoices';
  static const String expenses = '/expenses';
  static const String reports = '/reports';

  // الطاقم والعيادات
  static const String staff = '/staff';
  static const String clinics = '/clinics';
  static const String clinicDetails = '/clinics/:id';

  // الإعدادات والاشتراكات
  static const String settings = '/settings';
  static const String settingsSubscription = '/settings/subscription';
}
