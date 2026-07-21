class AppStrings {
  AppStrings._();

  static bool isArabic = true;

  // General
  static String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  static String get delete => isArabic ? 'حذف' : 'Delete';
  static String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  static String get save => isArabic ? 'حفظ' : 'Save';
  static String get add => isArabic ? 'إضافة' : 'Add';
  static String get edit => isArabic ? 'تعديل' : 'Edit';
  static String get search => isArabic ? 'بحث' : 'Search';
  static String get all => isArabic ? 'الكل' : 'All';
  static String get today => isArabic ? 'اليوم' : 'Today';
  static String get error => isArabic ? 'خطأ' : 'Error';
  static String get success => isArabic ? 'تم بنجاح' : 'Success';
  static String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  static String get close => isArabic ? 'إغلاق' : 'Close';
  static String get noData => isArabic ? 'لا توجد بيانات' : 'No data';
  static String get loading => isArabic ? 'جارٍ التحميل' : 'Loading';
  static String get select => isArabic ? 'اختر' : 'Select';
  static String get optional => isArabic ? '(اختياري)' : '(Optional)';

  // Navigation / Bottom Nav
  static String get home => isArabic ? 'الرئيسية' : 'Home';
  static String get patients => isArabic ? 'المرضى' : 'Patients';
  static String get settings => isArabic ? 'الإعدادات' : 'Settings';
  static String get appointments => isArabic ? 'المواعيد' : 'Appointments';

  static String get createdAt => isArabic ? 'تاريخ الانشاء' : 'Created At';

  // Patients
  static String get patient => isArabic ? 'مريض' : 'Patient';
  static String get patientDetails =>
      isArabic ? 'تفاصيل المريض' : 'Patient Details';
  static String get addPatient => isArabic ? 'إضافة مريض' : 'Add Patient';
  static String get editPatient => isArabic ? 'تعديل المريض' : 'Edit Patient';
  static String get deletePatient => isArabic ? 'حذف المريض' : 'Delete Patient';
  static String get noPatients => isArabic ? 'لا يوجد مرضى' : 'No patients';
  static String get patientName => isArabic ? 'اسم المريض' : 'Patient Name';
  static String get patientPhone => isArabic ? 'رقم الجوال' : 'Phone Number';
  static String get patientAge => isArabic ? 'العمر' : 'Age';
  static String get patientGender => isArabic ? 'الجنس' : 'Gender';
  static String get male => isArabic ? 'ذكر' : 'Male';
  static String get female => isArabic ? 'أنثى' : 'Female';
  static String get allergies => isArabic ? 'الحساسية' : 'Allergies';
  static String get medicalHistory =>
      isArabic ? 'التاريخ المرضي' : 'Medical History';
  static String get lastVisit => isArabic ? 'آخر زيارة' : 'Last Visit';
  static String get patientDeleted =>
      isArabic ? 'تم حذف المريض بنجاح' : 'Patient deleted successfully';

  // Clinics
  static String get clinics => isArabic ? 'العيادات' : 'Clinics';
  static String get noClinics => isArabic ? 'لا توجد عيادات' : 'No Clinics';
  static String get addFirstClinic =>
      isArabic ? 'قم بإضافة أول عيادة لك الآن.' : 'Add your first clinic now.';
  static String get clinicDetails =>
      isArabic ? 'تفاصيل العيادة' : 'Clinic Details';
  static String get clinicNotFound =>
      isArabic ? 'العيادة غير موجودة' : 'Clinic not found';
  static String get loadFailed =>
      isArabic ? 'تعذر تحميل البيانات' : 'Failed to load data';
  static String get loadClinicsFailed =>
      isArabic ? 'تعذّر تحميل قائمة العيادات' : 'Failed to load clinics list';
  static String get myClinics => isArabic ? 'عياداتي' : 'My Clinics';
  static String get addClinic => isArabic ? 'إضافة عيادة' : 'Add Clinic';
  static String get clinicOverview => isArabic
      ? 'نظرة عامة على أداء جميع الفروع'
      : 'Overview of all branches performance';
  static String get getDirections =>
      isArabic ? 'احصل على الاتجاهات' : 'Get Directions';

  // Clinic card
  static String get disabled => isArabic ? 'معطل' : 'Disabled';
  static String get todayPatients =>
      isArabic ? 'مرضى اليوم' : "Today's Patients";
  static String get upcomingAppointments =>
      isArabic ? 'مواعيد قادمة' : 'Upcoming Appointments';
  static String get todayRevenue =>
      isArabic ? 'إيرادات اليوم' : "Today's Revenue";
  static String get sar => isArabic ? 'ر.س' : 'SAR';
  static String get editData => isArabic ? 'تعديل البيانات' : 'Edit Info';
  static String get disableClinic =>
      isArabic ? 'تعطيل العيادة' : 'Disable Clinic';
  static String get enableClinic =>
      isArabic ? 'تفعيل العيادة' : 'Enable Clinic';
  static String get deleteClinic => isArabic ? 'حذف العيادة' : 'Delete Clinic';
  static String get toggleClinic => isArabic ? 'تعطيل' : 'Disable';

  // Confirm dialogs
  static String get confirmDelete =>
      isArabic ? 'تأكيد الحذف' : 'Confirm Delete';
  static String confirmDeleteClinic(String name) => isArabic
      ? 'هل أنت متأكد من حذف "$name"؟'
      : 'Are you sure you want to delete "$name"?';
  static String get confirmDeleteAction => isArabic
      ? 'هل أنت متأكد من حذف هذه العيادة؟ لا يمكن التراجع عن هذا الإجراء.'
      : 'Are you sure you want to delete this clinic? This action cannot be undone.';
  static String get deletedSuccess => isArabic ? 'تم حذف' : 'Deleted';
  static String get toggledSuccess => isArabic ? 'تم ' : 'Success ';
  static String get updatedSuccess =>
      isArabic ? 'تم تحديث بيانات العيادة' : 'Clinic details updated';
  static String get addedSuccess =>
      isArabic ? 'تم إضافة العيادة' : 'Clinic added successfully';

  // Staff
  static String get staff => isArabic ? 'الطاقم الطبي' : 'Staff';
  static String get addMember => isArabic ? 'إضافة عضو' : 'Add Member';
  static String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  static String get noStaff => isArabic
      ? 'لا يوجد طاقم طبي في هذه العيادة'
      : 'No medical staff in this clinic';
  static String get removeFromStaff =>
      isArabic ? 'إزالة من الطاقم' : 'Remove from staff';
  static String confirmRemoveStaff(String name) => isArabic
      ? 'هل أنت متأكد من رغبتك في إزالة "$name" من طاقم هذه العيادة؟'
      : 'Are you sure you want to remove "$name" from this clinic\'s staff?';
  static String get remove => isArabic ? 'إزالة' : 'Remove';
  static String get addMemberToStaff =>
      isArabic ? 'إضافة عضو إلى الطاقم' : 'Add Member to Staff';
  static String get newMember => isArabic ? 'عضو جديد' : 'New Member';
  static String get newMemberDesc => isArabic
      ? 'دعوة طبيب أو سكرتير جديد بالبريد الإلكتروني'
      : 'Invite a new doctor or secretary by email';
  static String get existingMember => isArabic
      ? 'عضو موجود في عيادة أخرى'
      : 'Existing member in another clinic';
  static String get existingMemberDesc => isArabic
      ? 'إضافة عضو مسجل بالفعل في إحدى عياداتك الأخرى'
      : 'Add a member already registered in another clinic';
  static String get filterByRole =>
      isArabic ? 'تصفية حسب الدور:' : 'Filter by role:';
  static String get selectMember => isArabic ? 'اختر العضو:' : 'Select member:';
  static String get noMembersInRole => isArabic
      ? 'لا يوجد أعضاء بهذا الدور في العيادات الأخرى.'
      : 'No members with this role in other clinics.';
  static String get addToClinicSameRole =>
      isArabic ? 'إضافة للعيادة بنفس الدور' : 'Add to clinic with same role';
  static String get selectAssociatedDoctor =>
      isArabic ? 'اختر الطبيب المرتبط:' : 'Select associated doctor:';
  static String get noDoctorsAvailable => isArabic
      ? 'لا يوجد أطباء متاحين في هذه العيادة.'
      : 'No doctors available in this clinic.';
  static String get inviteStaff => isArabic ? 'دعوة موظف' : 'Invite Staff';
  static String get pendingInvitations =>
      isArabic ? 'دعوات معلقة' : 'Pending Invitations';
  static String get changeRole => isArabic ? 'تغيير الدور' : 'Change Role';
  static String get suspendAccount =>
      isArabic ? 'تعليق الحساب' : 'Suspend Account';
  static String get reactivateAccount =>
      isArabic ? 'إعادة التفعيل' : 'Reactivate';
  static String get accountSuspended =>
      isArabic ? 'تم تعليق حساب الموظف' : 'Staff account suspended';
  static String get accountReactivated =>
      isArabic ? 'تم إعادة تفعيل الحساب' : 'Account reactivated';
  static String get availableNow => isArabic ? 'متاح الآن' : 'Available Now';
  static String get offline => isArabic ? 'غير متصل' : 'Offline';
  static String get viewProfile => isArabic ? 'عرض الملف' : 'View Profile';
  static String get lastSeenYesterday =>
      isArabic ? 'آخر ظهور: أمس' : 'Last seen: Yesterday';
  static String get filterByClinic =>
      isArabic ? 'تصفية حسب العيادة' : 'Filter by clinic';
  static String get allClinics => isArabic ? 'كل العيادات' : 'All Clinics';
  static String get inviteNewStaff =>
      isArabic ? 'دعوة موظف جديد' : 'Invite New Staff';

  // Role labels
  static String roleLabel(String role) {
    if (isArabic) {
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
    } else {
      switch (role) {
        case 'doctor':
          return 'Doctor';
        case 'nurse':
          return 'Nurse';
        case 'accountant':
          return 'Accountant';
        case 'secretary':
          return 'Secretary';
        case 'owner':
          return 'Owner';
        default:
          return role;
      }
    }
  }

  // Summary cards
  static String get todayAppointments =>
      isArabic ? 'مواعيد اليوم' : "Today's Appointments";
  static String remainingAppointments(int count) =>
      isArabic ? 'متبقي $count' : '$count remaining';
  static String get doctors => isArabic ? 'الأطباء' : 'Doctors';
  static String onLeave(int count) =>
      isArabic ? '$count في إجازة' : '$count on leave';
  static String get active => isArabic ? 'نشط' : 'Active';
  static String get none => isArabic ? 'لا يوجد' : 'None';
  static String get egp => isArabic ? 'ج.م' : 'EGP';
  static String get monthlyRevenue =>
      isArabic ? 'إيرادات الشهر' : 'Monthly Revenue';
  static String get completedAppointments =>
      isArabic ? 'المواعيد المكتملة' : 'Completed Appointments';
  static String get overallRating =>
      isArabic ? 'التقييم العام' : 'Overall Rating';
  static String get outOfFive => ' / 5.0';
  static String reviewCount(int count) =>
      isArabic ? 'من $count مراجعة' : 'from $count reviews';
  static String get totalRevenue =>
      isArabic ? 'إجمالي الإيرادات' : 'Total Revenue';
  static String get totalPatients =>
      isArabic ? 'إجمالي المرضى' : 'Total Patients';
  static String get activeClinics =>
      isArabic ? 'العيادات النشطة' : 'Active Clinics';

  // Header
  static String get openNow => isArabic ? 'مفتوح الآن' : 'Open Now';
  static String get mainBranch => isArabic ? 'رئيسية' : 'Main';

  // Working hours
  static String get workingHours => isArabic ? 'ساعات العمل' : 'Working Hours';
  static String get closed => isArabic ? 'مغلق' : 'Closed';
  static List<String> get dayNames => isArabic
      ? [
          'الأحد',
          'الإثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت'
        ]
      : [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday'
        ];
  static const List<String> dayKeys = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ];

  // Visit types
  static String get visitTypesAndPrices =>
      isArabic ? 'أنواع الزيارات والأسعار' : 'Visit Types & Prices';
  static String get addService => isArabic ? 'إضافة خدمة' : 'Add Service';
  static String get noServices =>
      isArabic ? 'لا توجد خدمات مسجلة' : 'No registered services';

  // Performance
  static String get clinicPerformance => isArabic
      ? 'أداء العيادة (الشهور الأخيرة)'
      : 'Clinic Performance (Recent Months)';
  static List<String> get shortMonths => isArabic
      ? ['فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو']
      : ['Feb', 'Mar', 'Apr', 'May', 'Jun'];

  // Actions sheet
  static String get viewDetails => isArabic ? 'عرض التفاصيل' : 'View Details';

  // Dashboard & Reception
  static String get liveQueue => isArabic ? 'الانتظار المباشر' : 'Live Queue';
  static String get todayQueue =>
      isArabic ? 'طابور الانتظار اليوم' : 'Today\'s Queue';
  static String get noPatientsWaiting => isArabic
      ? 'لا يوجد مرضى بانتظار الدخول حالياً.'
      : 'No patients waiting to enter currently.';
  static String get call => isArabic ? 'استدعاء' : 'Call';
  static String get callNext => isArabic ? 'استدعاء التالي' : 'Call Next';
  static String get atDoctor => isArabic ? 'عند الطبيب' : 'At Doctor';
  static String get urgent => isArabic ? 'مستعجل' : 'Urgent';
  static String get dailyInvoices =>
      isArabic ? 'الفواتير اليوم' : 'Daily Invoices';
  static String get dailyCollected =>
      isArabic ? 'المحصل اليوم' : 'Daily Collected';
  static String get totalAppointmentsStr =>
      isArabic ? 'إجمالي المواعيد' : 'Total Appointments';
  static String get quickActions =>
      isArabic ? 'إجراءات سريعة' : 'Quick Actions';
  static String get secretaryDashboardTitle =>
      isArabic ? 'الاستقبال والعيادة' : 'Reception & Clinic';
  static String get welcomeBack => isArabic ? 'مرحباً، ' : 'Welcome, ';
  static String get receptionOffice =>
      isArabic ? 'مكتب الاستقبال' : 'Reception Desk';
  static String get waitingQueueTitle =>
      isArabic ? 'قائمة الانتظار' : 'Waiting Queue';
  static String get invoices => isArabic ? 'الفواتير' : 'Invoices';
  static String get queueEmpty => isArabic ? 'الطابور فارغ' : 'Queue is empty';
  static String get queueEmptyDesc => isArabic
      ? 'لا يوجد مرضى في طابور الانتظار حالياً.'
      : 'No patients in the waiting queue currently.';
  static String get patientCalled =>
      isArabic ? 'تم استدعاء المريض التالي' : 'Next patient called';
  static String get patientCalledDetails =>
      isArabic ? 'تم استدعاء المريض' : 'Patient has been called';
  static String get finished => isArabic ? 'انتهى' : 'Finished';
  static String get patientsInQueue =>
      isArabic ? 'المرضى في الطابور' : 'Patients in Queue';
  static String get pressCallNext => isArabic
      ? 'اضغط على "استدعاء التالي" للبدء'
      : 'Press "Call Next" to start';
  static String get normalCheckup => isArabic ? 'كشف عادي' : 'Normal Checkup';
  static String get emergencyBanner =>
      isArabic ? 'حالة طارئة — أولوية قصوى' : 'Emergency — Highest Priority';
  static String get emergencyPriorityDescription => isArabic
      ? 'سيحصل على الأولوية في الانتظار'
      : 'Will get priority in waiting';

  // Invoices
  static String get invoice => isArabic ? 'الفاتورة' : 'Invoice';
  static String get invoiceNumber =>
      isArabic ? 'رقم الفاتورة' : 'Invoice Number';
  static String get viewInvoice => isArabic ? 'عرض الفاتورة' : 'View Invoice';
  static String get noInvoiceYet =>
      isArabic ? 'لم تُسجَّل فاتورة بعد' : 'No invoice recorded yet';
  static String get createInvoice =>
      isArabic ? 'إنشاء فاتورة' : 'Create Invoice';
  static String get paid => isArabic ? 'مدفوع' : 'Paid';
  static String get cash => isArabic ? 'نقدي' : 'Cash';
  static String get card => isArabic ? 'بطاقة' : 'Card';
  static String get transfer => isArabic ? 'حوالة' : 'Transfer';
  static String get total => isArabic ? 'الإجمالي' : 'Total';
  static String get amount => isArabic ? 'المبلغ' : 'Amount';
  static String get paymentMethod =>
      isArabic ? 'طريقة الدفع' : 'Payment Method';
  static String get date => isArabic ? 'التاريخ' : 'Date';
  static String get addInvoice => isArabic ? 'إضافة فاتورة' : 'Add Invoice';
  static String get invoiceDeleted =>
      isArabic ? 'تم حذف الفاتورة' : 'Invoice deleted';

  // Expenses
  static String get expenses => isArabic ? 'المصروفات' : 'Expenses';
  static String get addExpense => isArabic ? 'إضافة مصروف' : 'Add Expense';
  static String get editExpense => isArabic ? 'تعديل المصروف' : 'Edit Expense';
  static String get deleteExpense =>
      isArabic ? 'حذف المصروف' : 'Delete Expense';
  static String get totalExpenses =>
      isArabic ? 'إجمالي المصروفات' : 'Total Expenses';
  static String get expenseCategory => isArabic ? 'التصنيف' : 'Category';
  static String get expenseName => isArabic ? 'البيان' : 'Description';
  static String get noExpenses => isArabic ? 'لا توجد مصروفات' : 'No expenses';
  static String get expenseDeleted =>
      isArabic ? 'تم حذف المصروف' : 'Expense deleted';

  // Reports
  static String get reports => isArabic ? 'التقارير' : 'Reports';
  static String get financialReports =>
      isArabic ? 'التقارير المالية' : 'Financial Reports';
  static String get reportExported =>
      isArabic ? 'تم تصدير التقرير بنجاح' : 'Report exported successfully';
  static String get revenue => isArabic ? 'الإيرادات' : 'Revenue';
  static String get revenueVsExpenses =>
      isArabic ? 'الإيرادات مقابل المصروفات' : 'Revenue vs Expenses';
  static String get doctorPerformance =>
      isArabic ? 'أداء الأطباء' : 'Doctor Performance';
  static String get patientsPerDoctor =>
      isArabic ? 'عدد المرضى لكل طبيب' : 'Patients per Doctor';
  static String get topServices => isArabic ? 'أبرز الخدمات' : 'Top Services';
  static String get monthly => isArabic ? 'شهري' : 'Monthly';
  static String get weekly => isArabic ? 'أسبوعي' : 'Weekly';
  static String get customRange => isArabic ? 'مخصص' : 'Custom';

  // Prescription / Drugs
  static String get drugs => isArabic ? 'الأدوية' : 'Drugs';
  static String get drug => isArabic ? 'دواء' : 'Drug';
  static String get drugBase => isArabic ? 'قاعدة الأدوية' : 'Drug Base';
  static String get addDrug => isArabic ? 'إضافة دواء' : 'Add Drug';
  static String get editDrug => isArabic ? 'تعديل الدواء' : 'Edit Drug';
  static String get deleteDrug =>
      isArabic ? 'حذف الدواء من القاعدة' : 'Delete drug from base';
  static String get drugName => isArabic ? 'اسم الدواء' : 'Drug Name';
  static String get drugCategory => isArabic ? 'التصنيف' : 'Category';
  static String get noDrugs => isArabic ? 'لا توجد أدوية' : 'No drugs';
  static String get switchToScientific =>
      isArabic ? 'الاسم العلمي' : 'Scientific Name';
  static String get dosage => isArabic ? 'الجرعة' : 'Dosage';
  static String get frequency => isArabic ? 'التكرار' : 'Frequency';
  static String get duration => isArabic ? 'المدة' : 'Duration';
  static String get timing => isArabic ? 'التوقيت' : 'Timing';
  static String get durationThreeDays => isArabic ? '٣ أيام' : '3 days';
  static String get durationSevenDays => isArabic ? '٧ أيام' : '7 days';
  static String get durationTenDays => isArabic ? '١٠ أيام' : '10 days';
  static String get durationFourteenDays => isArabic ? '١٤ يوم' : '14 days';
  static String get durationThirtyDays => isArabic ? '٣٠ يوم' : '30 days';
  static String get durationContinuing => isArabic ? 'مستمر' : 'Continuous';
  static String get timingBeforeMeal => isArabic ? 'قبل الأكل' : 'Before meal';
  static String get timingAfterMeal => isArabic ? 'بعد الأكل' : 'After meal';
  static String get timingWithMeal => isArabic ? 'مع الأكل' : 'With meal';
  static String get timingAnyTime => isArabic ? 'في أي وقت' : 'Any time';
  static String get notes => isArabic ? 'ملاحظات' : 'Notes';
  static String get whenNeeded =>
      isArabic ? 'عند اللزوم (PRN)' : 'When Needed (PRN)';
  static String get frequencyOnce => isArabic ? 'مرة يومياً' : 'Once daily';
  static String get frequencyTwice => isArabic ? 'مرتين يومياً' : 'Twice daily';
  static String get frequencyThrice =>
      isArabic ? '٣ مرات يومياً' : '3 times daily';
  static String get frequencyFour =>
      isArabic ? '٤ مرات يومياً' : '4 times daily';
  static String get frequencyOnDemand =>
      isArabic ? 'عند اللزوم' : 'When needed';
  static String get copyLastPrescription =>
      isArabic ? 'نسخ اخر روشته' : 'Copy Last Prescription';

  // Prescription
  static String get prescription => isArabic ? 'الروشتة' : 'Prescription';
  static String get prescriptionLabel =>
      isArabic ? 'الروشتة الطبية' : 'Medical Prescription';
  static String get printPrescription =>
      isArabic ? 'طباعة الروشتة' : 'Print Prescription';
  static String get noPrescription =>
      isArabic ? 'لم تُصدر روشتة بعد' : 'No prescription issued yet';
  static String get newPrescription =>
      isArabic ? 'إصدار روشتة جديدة' : 'Issue New Prescription';
  static String get saveAndFinish => isArabic ? 'حفظ وإنهاء' : 'Save & Finish';
  static String get print => isArabic ? 'طباعة' : 'Print';
  static String get diagnosis => isArabic ? 'التشخيص' : 'Diagnosis';
  static String get medicalDiagnosis =>
      isArabic ? 'التشخيص الطبي' : 'Medical Diagnosis';
  static String get diagnosisHint => isArabic
      ? 'أدخل تشخيص مخصص للزيارة الحالية...'
      : 'Enter a diagnosis for this visit...';
  static String get addDiagnosis => isArabic ? 'إضافة' : 'Add';
  static String get searchDrugs => isArabic
      ? 'ابحث عن دواء باسمه العلمي أو التجاري...'
      : 'Search by drug name...';
  static String get visitType => isArabic ? 'نوع الزيارة' : 'Visit Type';
  static String get doctorLabel =>
      isArabic ? 'الطبيب المعالج' : 'Attending Doctor';

  // Templates
  static String get template => isArabic ? 'القالب' : 'Template';
  static String get templates => isArabic ? 'القوالب' : 'Templates';
  static String get addTemplate => isArabic ? 'إضافة قالب' : 'Add Template';
  static String get editTemplate => isArabic ? 'تعديل القالب' : 'Edit Template';
  static String get deleteTemplate =>
      isArabic ? 'حذف القالب' : 'Delete Template';
  static String get noTemplates => isArabic ? 'لا توجد قوالب' : 'No templates';
  static String get templateName => isArabic ? 'اسم القالب' : 'Template Name';
  static String get templateCategory =>
      isArabic ? 'تصنيف القالب' : 'Template Category';

  // Appointments
  static String get appointment => isArabic ? 'موعد' : 'Appointment';
  static String get appointmentDetails =>
      isArabic ? 'تفاصيل الموعد' : 'Appointment Details';
  static String get newAppointment =>
      isArabic ? 'موعد جديد' : 'New Appointment';
  static String get appointmentDeleted =>
      isArabic ? 'تم إلغاء الموعد' : 'Appointment cancelled';
  static String get appointmentType =>
      isArabic ? 'نوع الموعد' : 'Appointment Type';
  static String get cost => isArabic ? 'التكلفة' : 'Cost';
  static String get status => isArabic ? 'الحالة' : 'Status';
  static String get scheduled => isArabic ? 'مجدول' : 'Scheduled';
  static String get confirmed => isArabic ? 'مؤكد' : 'Confirmed';
  static String get inProgress => isArabic ? 'قيد الكشف' : 'In Progress';
  static String get completed => isArabic ? 'منتهي' : 'Completed';
  static String get cancelled => isArabic ? 'ملغي' : 'Cancelled';
  static String get booked => isArabic ? 'حُجز' : 'Booked';
  static String get arrived => isArabic ? 'وصل' : 'Arrived';
  static String get inside => isArabic ? 'داخل' : 'Inside';
  static String get appointmentCancelled =>
      isArabic ? 'تم إلغاء هذا الموعد' : 'This appointment was cancelled';
  static String get bookAppointment =>
      isArabic ? 'حجز موعد' : 'Book Appointment';
  static String get tabToday => isArabic ? 'اليوم' : 'Today';
  static String get tabUpcoming => isArabic ? 'القادمة' : 'Upcoming';
  static String get tabHistory => isArabic ? 'السجل' : 'History';
  static String get selectPatient =>
      isArabic ? 'اختيار المريض' : 'Select Patient';
  static String get searchPatientHint =>
      isArabic ? 'ابحث أو اختر مريضاً...' : 'Search or select a patient...';
  static String get searchByName =>
      isArabic ? 'بحث بالاسم...' : 'Search by name...';
  static String get queueTooltip =>
      isArabic ? 'طابور الانتظار' : 'Waiting Queue';

  // Settings Screen
  static String get management => isArabic ? 'الإدارة' : 'Management';
  static String get manageDrugs =>
      isArabic ? 'إدارة الأدوية' : 'Drugs Management';
  static String get prescriptionTemplates =>
      isArabic ? 'قوالب الروشتات' : 'Prescription Templates';
  static String get visitTypes => isArabic ? 'أنواع الزيارات' : 'Visit Types';
  static String get visitTypesDesc =>
      isArabic ? 'لتحديد أسعار الكشف' : 'To set examination prices';
  static String get editDoctorSchedule =>
      isArabic ? 'لتعديل مواعيد الطبيب' : 'To edit doctor\'s hours';
  static String get queueSystem =>
      isArabic ? 'نظام قائمة الانتظار' : 'Queue System';
  static String get currentPattern =>
      isArabic ? 'النمط الحالي:' : 'Current Pattern:';
  static String get other => isArabic ? 'أخرى' : 'Other';
  static String get darkMode => isArabic ? 'المظهر الداكن' : 'Dark Mode';
  static String get appearanceDarkMode =>
      isArabic ? 'المظهر - الوضع الليلي' : 'Appearance - Dark Mode';
  static String get appearance => isArabic ? 'المظهر' : 'Appearance';
  static String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  static String get account => isArabic ? 'الحساب' : 'Account';
  static String get editProfile =>
      isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile';
  static String get editProfileShort =>
      isArabic ? 'تعديل الملف' : 'Edit Profile';
  static String get clinic => isArabic ? 'العيادة' : 'Clinic';
  static String get changeClinic =>
      isArabic ? 'تغيير العيادة' : 'Change Clinic';
  static String get currentDoctor =>
      isArabic ? 'الطبيب الحالي' : 'Current Doctor';
  static String get changeDoctor => isArabic ? 'تغيير الطبيب' : 'Change Doctor';
  static String get noDoctorSelected =>
      isArabic ? 'لم يتم اختيار طبيب' : 'No doctor selected';
  static String get manageStaff =>
      isArabic ? 'إدارة الطاقم' : 'Staff Management';
  static String get inviteMember => isArabic ? 'دعوة عضو' : 'Invite Member';
  static String get subscriptionAndPlan =>
      isArabic ? 'الاشتراك والخطة' : 'Subscription & Plan';
  static String get enterAsDoctor =>
      isArabic ? 'الدخول كطبيب' : 'Enter as Doctor';
  static String get switchBackToOwner =>
      isArabic ? 'العودة كمالك' : 'Switch back to Owner';
  static String get selectClinicToEnter =>
      isArabic ? 'اختر العيادة للدخول' : 'Select clinic to enter';
  static String get doctorRoleLabel => isArabic ? 'طبيب' : 'Doctor';
  static String get ownerRoleLabel => isArabic ? 'مالك' : 'Owner';
  static String get secretaryRoleLabel => isArabic ? 'سكرتيرة' : 'Secretary';
  static String get language => isArabic ? 'لغة التطبيق' : 'Language';
  static String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  static String get mobileNumber => isArabic ? 'رقم الموبايل' : 'Mobile Number';
  static String get saveChanges => isArabic ? 'حفظ التغييرات' : 'Save Changes';
  static String get changesSaved =>
      isArabic ? 'تم حفظ التغييرات' : 'Changes saved';
  static String get currentClinic =>
      isArabic ? 'العيادة الحالية' : 'Current Clinic';
  static String get allSystemsNormal => isArabic
      ? 'جميع الأنظمة تعمل بشكل طبيعي'
      : 'All systems are running normally';
  static String get normalSlot => isArabic ? 'عادي' : 'Normal';
  static String get revisit => isArabic ? 'مراجعة' : 'Revisit';
  static String get consultation => isArabic ? 'استشارة' : 'Consultation';
  static String get repeatsEvery => isArabic ? 'يتكرر كل ' : 'Repeats every ';
  static String get patientsCount => isArabic ? ' مرضى' : ' patients';
  static String get planAndSubscription =>
      isArabic ? 'الاشتراك والخطة' : 'Subscription & Plan';
  static String get manageSubscription => isArabic
      ? 'إدارة باقة العيادة، ومراقبة الاستهلاك، وتحديث معلومات الدفع.'
      : 'Manage your clinic plan, monitor usage, and update payment info.';
  static String get billingHistory =>
      isArabic ? 'سجل الفواتير' : 'Billing History';
  static String get noBillingHistory =>
      isArabic ? 'لا توجد فواتير سابقة.' : 'No previous invoices.';
  static String get trial => isArabic ? 'تجريبي' : 'Trial';
  static String get selectClinic => isArabic ? 'اختر العيادة' : 'Select Clinic';
  static String get selectDoctor =>
      isArabic ? 'اختر الطبيب الحالي' : 'Select Current Doctor';
  // static String get noDoctorsAvailable =>
  //     isArabic ? 'لا يوجد أطباء مسجلين...' : 'No registered doctors...';
  static String get addToClinic => isArabic ? 'إضافة للعيادة' : 'Add to Clinic';
  static String get currentPlan => isArabic ? 'الباقة الحالية' : 'Current Plan';
  static String get planUsage =>
      isArabic ? 'استهلاك الباقة الحالية' : 'Current Plan Usage';
  static String get users => isArabic ? 'المستخدمين' : 'Users';
  static String get branches => isArabic ? 'الفروع' : 'Branches';

  // Auth
  static String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  static String get createAccount => isArabic ? 'إنشاء حساب' : 'Create Account';
  static String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  static String get password => isArabic ? 'كلمة المرور' : 'Password';
  static String get confirmPassword =>
      isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  static String get phoneNumber => isArabic ? 'رقم الجوال' : 'Phone Number';
  static String get welcomeTitle =>
      isArabic ? 'نظام إدارة العيادات الذكي' : 'Smart Clinic Management System';
  static String get smartManagement =>
      isArabic ? 'نظام إدارة العيادات الذكي' : 'Smart Clinic Management';
  static String get acceptInvitation =>
      isArabic ? 'قبول الدعوة' : 'Accept Invitation';
  static String get welcomeGreeting => isArabic ? 'أهلاً بك' : 'Welcome';
  static String get loginSubtitle => isArabic
      ? 'سجّل الدخول للوصول إلى لوحة تحكم عيادتك المتقدمة.'
      : 'Log in to access your advanced clinic dashboard.';
  static String get continueWithGoogle =>
      isArabic ? 'المتابعة باستخدام Google' : 'Continue with Google';
  static String get continueWithApple =>
      isArabic ? 'المتابعة باستخدام Apple' : 'Continue with Apple';
  static String get orText => isArabic ? 'أو' : 'Or';
  static String get loginAsDoctor =>
      isArabic ? 'دخول كطبيب' : 'Login as Doctor';
  static String get loginAsSecretary =>
      isArabic ? 'دخول كسكرتارية' : 'Login as Secretary';
  static String get newClinicOwner => isArabic
      ? 'صاحب عيادة جديد؟ أنشئ حساباً'
      : 'New clinic owner? Create an account';
  static String get teamViaInvite => isArabic
      ? 'أعضاء الفريق يُضافون عبر الدعوة'
      : 'Team members are added via invitation';
  static String get orRegisterWith =>
      isArabic ? 'أو التسجيل باستخدام' : 'Or register with';
  static String get joinInvitation =>
      isArabic ? 'دعوة انضمام' : 'Join Invitation';
  static String get invitationDescription => isArabic
      ? 'لقد تمت دعوتك للانضمام إلى طاقم عيادة "كليوباترا لطب الأطفال".\nالرجاء قبول الدعوة للبدء.'
      : 'You have been invited to join the "Cleopatra Pediatrics" clinic team.\nPlease accept the invitation to start.';
  static String get acceptAndLogin =>
      isArabic ? 'قبول وتسجيل الدخول' : 'Accept & Login';
  static String get agreeToTerms => isArabic
      ? 'أوافق على الشروط والأحكام'
      : 'I agree to the terms and conditions';
  static String get sendMagicLink =>
      isArabic ? 'إرسال رابط الدخول' : 'Send Magic Link';

  // Onboarding
  static String get choosePlan => isArabic ? 'اختر الباقة' : 'Choose Plan';
  static String get step => isArabic ? 'الخطوة ' : 'Step ';
  static String get of => isArabic ? ' من ' : ' of ';
  static String get inviteDoctors =>
      isArabic ? 'دعوة الأطباء' : 'Invite Doctors';
  static String get skip => isArabic ? 'تخطي' : 'Skip';

  static String get accountVerification =>
      isArabic ? 'تأكيد الحساب' : 'Account Verification';
  static String get verificationEmailSent => isArabic
      ? 'تم إرسال رابط التفعيل إلى بريدك الإلكتروني بنجاح. يرجى الضغط على الرابط في رسالة البريد الإلكتروني لتفعيل حسابك ثم المتابعة.'
      : 'A verification link has been successfully sent to your email. Please click the link in the email to activate your account and then click continue.';
  static String get continueLabel => isArabic ? 'متابعة' : 'Continue';
  static String get next => isArabic ? 'التالي' : 'Next';
  static String get getStarted => isArabic ? 'ابدأ الآن' : 'Get Started';
  static String get clinicData => isArabic ? 'بيانات العيادة' : 'Clinic Data';
  static String get editClinicData =>
      isArabic ? 'تعديل بيانات العيادة' : 'Edit Clinic Data';
  static String get addNewClinic =>
      isArabic ? 'إضافة عيادة جديدة' : 'Add New Clinic';
  static String get logoOptional =>
      isArabic ? 'صورة الشعار (اختياري)' : 'Logo Image (Optional)';
  static String get clinicName => isArabic ? 'اسم العيادة' : 'Clinic Name';
  static String get enterClinicNameHint =>
      isArabic ? 'أدخل اسم العيادة' : 'Enter clinic name';
  static String get specialty => isArabic ? 'التخصص' : 'Specialty';
  static String get selectSpecialty =>
      isArabic ? 'اختر التخصص' : 'Select Specialty';
  static String get generalMedicine => isArabic ? 'طب عام' : 'General Medicine';
  static String get dentalMedicine => isArabic ? 'طب أسنان' : 'Dentistry';
  static String get pediatrics => isArabic ? 'طب أطفال' : 'Pediatrics';
  static String get cardiology => isArabic ? 'قلبية' : 'Cardiology';
  static String get address => isArabic ? 'العنوان' : 'Address';
  static String get addressHint =>
      isArabic ? 'المدينة، الحي، الشارع' : 'City, District, Street';
  static String get areYouDoctor => isArabic
      ? 'هل أنت طبيب في هذه العيادة؟'
      : 'Are you a doctor in this clinic?';
  static String get autoAddAsDoctor => isArabic
      ? 'سيتم إضافتك كطبيب تلقائياً'
      : 'You will be automatically added as a doctor';
  static String get createClinicAndContinue =>
      isArabic ? 'إنشاء العيادة والمتابعة' : 'Create clinic and continue';
  static String get backToPrevious =>
      isArabic ? 'العودة للسابق' : 'Back to previous';
  static String get chooseYourPlan =>
      isArabic ? 'اختر خطتك' : 'Choose Your Plan';
  static String get planSubtitle => isArabic
      ? 'اكتشف الباقة التي تناسب حجم عيادتك وتطلعاتك.'
      : 'Discover the plan that fits your clinic size and aspirations.';
  static String get monthlyLabel => isArabic ? 'شهري' : 'Monthly';
  static String get yearlyLabel => isArabic ? 'سنوي' : 'Yearly';
  static String get lifetimeLabel => isArabic ? 'مدى الحياة' : 'Lifetime';
  static String get basicPlan => isArabic ? 'الأساسية' : 'Basic';
  static String get professionalPlan =>
      isArabic ? 'الاحترافية' : 'Professional';
  static String get enterprisePlan => isArabic ? 'المؤسسات' : 'Enterprise';
  static String get perMonth => isArabic ? '/ شهرياً' : '/month';
  static String get perYear => isArabic ? '/ سنوياً' : '/year';
  static String get lifetimeSuffix => isArabic ? ' مدى الحياة' : ' Lifetime';
  static String get mostPopular => isArabic ? 'الأكثر طلباً' : 'Most Popular';
  static String get planSelected =>
      isArabic ? 'تم تحديد الباقة' : 'Plan Selected';
  static String get selectPlan => isArabic ? 'اختيار الخطة' : 'Select Plan';
  static String get startFreeTrial =>
      isArabic ? 'ابدأ التجربة المجانية ' : 'Start Free Trial ';
  static String get daysUnit => isArabic ? ' يوم' : ' days';
  static String get inviteTeam => isArabic ? 'دعوة الفريق' : 'Invite Team';
  static String get inviteTeamDescription => isArabic
      ? 'قم بدعوة زملائك في العيادة للانضمام إلى النظام بصلاحيات محددة.'
      : 'Invite your clinic colleagues to join the system with specific permissions.';
  static String get enterEmployeeName => isArabic
      ? 'الرجاء إدخال اسم الموظف الكامل'
      : 'Please enter the full employee name';
  static String get emailAlreadyAdded => isArabic
      ? 'هذا البريد مضاف مسبقاً في القائمة'
      : 'This email is already in the list';
  static String get sendInvitations =>
      isArabic ? 'إرسال الدعوات' : 'Send Invitations';
  static String get associatedClinic =>
      isArabic ? 'العيادة المرتبطة' : 'Associated Clinic';
  static String get employeeFullName =>
      isArabic ? 'الاسم الكامل للموظف' : 'Employee Full Name';
  static String get rolePermission =>
      isArabic ? 'الصلاحية (الدور)' : 'Role (Permission)';
  static String get responsibleDoctor => isArabic
      ? 'الطبيب المسؤول عنه (اختياري)'
      : 'Responsible Doctor (Optional)';
  static String get addToInviteList =>
      isArabic ? 'إضافة إلى قائمة المدعوين' : 'Add to Invite List';
  static String inviteesCount(int count) =>
      isArabic ? 'المدعوين ($count)' : 'Invitees ($count)';
  static String doctorWithName(String name) =>
      isArabic ? 'الطبيب: $name' : 'Doctor: $name';
  static String supportClinics(int count) => isArabic
      ? 'دعم حتى $count عيادات نشطة'
      : 'Support up to $count active clinics';
  static String supportStaff(int count) => isArabic
      ? 'دعم حتى $count من طاقم العمل'
      : 'Support up to $count staff members';
  static String supportPatients(int count) => isArabic
      ? 'دعم حتى $count مريض مسجل'
      : 'Support up to $count registered patients';

  // Success / Error messages
  static String get loadFailedMsg =>
      isArabic ? 'تعذّر تحميل البيانات' : 'Failed to load data';
  static String get loadAppointmentsFailed =>
      isArabic ? 'تعذّر تحميل المواعيد' : 'Failed to load appointments';
  static String get loadPatientsFailed =>
      isArabic ? 'تعذّر تحميل المرضى' : 'Failed to load patients';
  static String get loadStaffFailed =>
      isArabic ? 'تعذّر تحميل قائمة الطاقم الطبي' : 'Failed to load staff list';
  static String get loadReportsFailed =>
      isArabic ? 'تعذّر تحميل التقارير' : 'Failed to load reports';
  static String get loadDrugsFailed =>
      isArabic ? 'تعذّر تحميل الأدوية' : 'Failed to load drugs';
  static String get loadTemplatesFailed =>
      isArabic ? 'تعذّر تحميل القوالب' : 'Failed to load templates';
  static String get roleChanged =>
      isArabic ? 'تم تغيير الدور إلى ' : 'Role changed to ';
  static String get operationSuccessful =>
      isArabic ? 'تمت العملية بنجاح' : 'Operation completed successfully';
  static String get unknownPatient =>
      isArabic ? 'مريض غير معروف' : 'Unknown patient';
  static String get unknownDrug => isArabic ? 'دواء غير معروف' : 'Unknown drug';
  static String get generalDoctor => isArabic ? 'طبيب عام' : 'General Doctor';
  static String get generalPractitioner =>
      isArabic ? 'طبيب معالج' : 'General Practitioner';
  static String get newOwner => isArabic ? 'مالك جديد' : 'New Owner';
  // Months
  static List<String> get fullMonths => isArabic
      ? [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ]
      : [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

  // Queue patterns
  static String get queuePatternNormal => isArabic ? 'عادي' : 'Normal';
  static String get queuePatternUrgent => isArabic ? 'مستعجل' : 'Urgent';
  static String get queuePatternRevisit => isArabic ? 'مراجعة' : 'Revisit';
  static String get queuePatternConsult =>
      isArabic ? 'استشارة' : 'Consultation';

  static String get bookingOrder => isArabic ? 'ترتيب الحجز' : 'Booking Order';
  static String get customPattern => isArabic ? 'نمط مخصص' : 'Custom Pattern';
  static String get scheduledAppointments => isArabic ? 'مواعيد بوقت محدد' : 'Scheduled Appointments';
  static String get arrivalOrder => isArabic ? 'ترتيب الحضور' : 'Arrival Order';
  static String get gallery => isArabic ? 'المعرض' : 'Gallery';
  static String get cameraLabel => isArabic ? 'الكاميرا' : 'Camera';
  static String get workingHoursSaved => isArabic ? 'تم حفظ مواعيد العمل بنجاح ✓' : 'Working hours saved successfully ✓';
  static String get visitTypesSaved => isArabic ? 'تم حفظ أنواع الزيارات بنجاح ✓' : 'Visit types saved successfully ✓';
  static String get patternSaved => isArabic ? 'تم حفظ النمط بنجاح' : 'Pattern saved successfully';
  static String get dragToReorder => isArabic ? 'اسحب لإعادة ترتيب الأنواع' : 'Drag to reorder types';
  static String get unsavedChanges => isArabic ? '(توجد تغييرات غير محفوظة)' : '(Unsaved changes)';
  static String get avgVisitTime => isArabic ? 'متوسط وقت الزيارة (بالدقائق):' : 'Average visit time (minutes):';
  static String get noTypesAdded => isArabic ? 'لم يتم إضافة أنواع بعد، أضف أول نوع' : 'No types added yet, add the first type';
  static String get addType => isArabic ? 'أضف نوع' : 'Add Type';
  static String get preview => isArabic ? 'معاينة' : 'Preview';
  static String get activeLabel => isArabic ? 'مباشر' : 'Active';
  static String get inactiveLabel => isArabic ? 'غير نشط' : 'Inactive';
  static String get newCycle => isArabic ? '── 🔁 دورة جديدة ──' : '── 🔁 New Cycle ──';
  static String get savePattern => isArabic ? 'حفظ النمط' : 'Save Pattern';
  static String get addVisitTypesFirst => isArabic ? 'يرجى إضافة أنواع الزيارات أولاً من الإعدادات' : 'Please add visit types first from settings';
  static String get selectTypeTitle => isArabic ? 'اختيار نوع' : 'Select Type';
  static String get patientHashPrefix => isArabic ? 'مريض #' : 'Patient #';
  static String get dayClosed => isArabic ? 'يوم مغلق - لا يوجد مواعيد' : 'Closed day - no appointments';
  static String get fromLabel => isArabic ? 'من' : 'From';
  static String get toLabel => isArabic ? 'إلى' : 'To';
  static String get addedTypes => isArabic ? 'الأنواع المضافة' : 'Added Types';
  static String get addVisitTypeLabel => isArabic ? 'أضف نوع زيارة' : 'Add Visit Type';
  static String get addNewTypeLabel => isArabic ? 'إضافة نوع جديد' : 'Add New Type';
  static String get selectTypeHint => isArabic ? 'اختر النوع' : 'Select type';
  static String get priceHint => isArabic ? 'السعر' : 'Price';
  static String get upgradeTitle => isArabic ? 'ارتقِ بعيادتك إلى المستوى التالي' : 'Elevate your clinic to the next level';
  static String get upgradeDesc => isArabic ? 'احصل على مساحة تخزين غير محدودة، فروع متعددة، وميزات الذكاء الاصطناعي المتقدمة.' : 'Get unlimited storage, multiple branches, and advanced AI features.';
  static String get upgradeNow => isArabic ? 'ترقية الخطة الآن' : 'Upgrade Plan Now';
  static String get trialEndingSoon => isArabic ? 'تنتهي الفترة التجريبية قريباً' : 'Trial period ending soon';
  static String get trialDesc => isArabic ? 'قم بترقية باقتك الآن لضمان استمرارية الوصول إلى جميع بيانات مرضاك بدون انقطاع.' : 'Upgrade your plan now to ensure uninterrupted access to all your patient data.';
  static String get daysRemaining => isArabic ? 'أيام متبقية' : 'Days remaining';
  static String get remainingCount => isArabic ? 'متبقي' : 'Remaining';
  static String get overLimit => isArabic ? 'تجاوز الحد المسموح' : 'Over the allowed limit';
  static String get addVisitType => isArabic ? 'أضف نوع زيارة' : 'Add Visit Type';
  static String get addNewVisitType => isArabic ? 'إضافة نوع جديد' : 'Add New Type';
  static String enterLabel(String label) => isArabic ? 'أدخل $label' : 'Enter $label';
  static String mapSlotTypeToLabel(String slotType) {
    switch (slotType) {
      case 'urgent':
        return isArabic ? 'مستعجل' : 'Urgent';
      case 'revisit':
        return isArabic ? 'مراجعة' : 'Revisit';
      case 'consult':
        return isArabic ? 'استشارة' : 'Consultation';
      default:
        return isArabic ? 'عادي' : 'Normal';
    }
  }

  // Drug categories
  static String get antibiotic => isArabic ? 'مضاد حيوي' : 'Antibiotic';
  static String get antipyretic => isArabic ? 'خافض حرارة' : 'Antipyretic';
  static String get respiratory => isArabic ? 'أمراض صدر' : 'Respiratory';
  static String get chronic => isArabic ? 'أدوية مزمنة' : 'Chronic';
  static String get otherCategory => isArabic ? 'أخرى' : 'Other';

  // Validation
  static String get enterFullName =>
      isArabic ? 'الرجاء إدخال الاسم بالكامل' : 'Please enter your full name';
  static String get enterEmail => isArabic
      ? 'الرجاء إدخال البريد الإلكتروني'
      : 'Please enter email address';
  static String get enterValidEmail => isArabic
      ? 'الرجاء إدخال بريد إلكتروني صالح'
      : 'Please enter a valid email address';
  static String get enterPassword =>
      isArabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter password';
  static String get passwordLengthError => isArabic
      ? 'يجب أن لا تقل كلمة المرور عن 6 أحرف'
      : 'Password must be at least 6 characters';
  static String get enterPhone =>
      isArabic ? 'الرجاء إدخال رقم الهاتف' : 'Please enter phone number';
  static String get agreeToTermsError => isArabic
      ? 'يجب الموافقة على الشروط والأحكام للاستمرار'
      : 'You must agree to the terms and conditions to continue';
}
