class AppStrings {
  AppStrings._();

  // General
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String retry = 'إعادة المحاولة';

  // Clinics
  static const String clinics = 'العيادات';
  static const String noClinics = 'لا توجد عيادات';
  static const String addFirstClinic = 'قم بإضافة أول عيادة لك الآن.';
  static const String clinicDetails = 'تفاصيل العيادة';
  static const String clinicNotFound = 'العيادة غير موجودة';
  static const String loadFailed = 'تعذر تحميل البيانات';
  static const String loadClinicsFailed = 'تعذّر تحميل قائمة العيادات';

  // Clinic card
  static const String disabled = 'معطل';
  static const String todayPatients = 'مرضى اليوم';
  static const String upcomingAppointments = 'مواعيد قادمة';
  static const String todayRevenue = 'إيرادات اليوم';
  static const String sar = 'ر.س';
  static const String editData = 'تعديل البيانات';
  static const String disableClinic = 'تعطيل العيادة';
  static const String enableClinic = 'تفعيل العيادة';
  static const String deleteClinic = 'حذف العيادة';

  // Confirm dialogs
  static const String confirmDelete = 'تأكيد الحذف';
  static String confirmDeleteClinic(String name) => 'هل أنت متأكد من حذف "$name"؟';
  static const String confirmDeleteAction = 'هل أنت متأكد من حذف هذه العيادة؟ لا يمكن التراجع عن هذا الإجراء.';
  static const String deletedSuccess = 'تم حذف';
  static const String toggledSuccess = 'تم ';
  static const String updatedSuccess = 'تم تحديث بيانات العيادة';
  static const String addedSuccess = 'تم إضافة العيادة';

  // Staff
  static const String staff = 'الطاقم الطبي';
  static const String addMember = 'إضافة عضو';
  static const String viewAll = 'عرض الكل';
  static const String noStaff = 'لا يوجد طاقم طبي في هذه العيادة';
  static const String removeFromStaff = 'إزالة من الطاقم';
  static String confirmRemoveStaff(String name) => 'هل أنت متأكد من رغبتك في إزالة "$name" من طاقم هذه العيادة؟';
  static const String remove = 'إزالة';
  static const String addMemberToStaff = 'إضافة عضو إلى الطاقم';
  static const String newMember = 'عضو جديد';
  static const String newMemberDesc = 'دعوة طبيب أو سكرتير جديد بالبريد الإلكتروني';
  static const String existingMember = 'عضو موجود في عيادة أخرى';
  static const String existingMemberDesc = 'إضافة عضو مسجل بالفعل في إحدى عياداتك الأخرى';
  static const String filterByRole = 'تصفية حسب الدور:';
  static const String selectMember = 'اختر العضو:';
  static const String noMembersInRole = 'لا يوجد أعضاء بهذا الدور في العيادات الأخرى.';
  static const String addToClinicSameRole = 'إضافة للعيادة بنفس الدور';

  // Role labels
  static String roleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'تمريض';
      case 'accountant':
        return 'محاسب';
      case 'secretary':
        return 'سكرتير';
      case 'owner':
        return 'مالك';
      default:
        return role;
    }
  }

  // Summary cards
  static const String todayAppointments = 'مواعيد اليوم';
  static String remainingAppointments(int count) => 'متبقي $count';
  static const String doctors = 'الأطباء';
  static String onLeave(int count) => '$count في إجازة';
  static const String active = 'نشط';
  static const String none = 'لا يوجد';
  static const String egp = 'ج.م';
  static const String monthlyRevenue = 'إيرادات الشهر';
  static const String completedAppointments = 'المواعيد المكتملة';
  static const String today = 'اليوم';
  static const String overallRating = 'التقييم العام';
  static String outOfFive = ' / 5.0';
  static String reviewCount(int count) => 'من $count مراجعة';

  // Header
  static const String openNow = 'مفتوح الآن';
  static const String mainBranch = 'رئيسية';

  // Working hours
  static const String workingHours = 'ساعات العمل';
  static const String closed = 'مغلق';
  static const List<String> dayNames = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  static const List<String> dayKeys = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

  // Visit types
  static const String visitTypesAndPrices = 'أنواع الزيارات والأسعار';
  static const String addService = 'إضافة خدمة';
  static const String noServices = 'لا توجد خدمات مسجلة';

  // Performance
  static const String clinicPerformance = 'أداء العيادة (الشهور الأخيرة)';
  static const List<String> shortMonths = ['فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];

  // Actions sheet
  static const String viewDetails = 'عرض التفاصيل';
}
