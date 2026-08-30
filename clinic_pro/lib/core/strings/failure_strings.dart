// ────────────────────────────────────────────────────────
// ملف مركزي لنصوص رسائل الأخطاء والـ Failures
// يدعم التبديل الديناميكي بين اللغتين العربية والإنجليزية
// ────────────────────────────────────────────────────────

import 'app_strings.dart';

class FailureStrings {
  FailureStrings._();

  static bool get _isAr => AppStrings.isArabic;

  // General & Network
  static String get networkError => _isAr
      ? 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة وإعادة المحاولة'
      : 'No internet connection. Please check your network and try again.';

  static String get unknownError =>
      _isAr ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';

  // Auth Failures
  static String get invalidCredentials => _isAr
      ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'
      : 'Invalid email or password.';

  static String get userNotFound => _isAr
      ? 'لم يتم العثور على بيانات المستخدم.'
      : 'User account not found.';

  static String get emailAlreadyInUse => _isAr
      ? 'البريد الإلكتروني مستخدم بالفعل.'
      : 'Email is already in use.';

  static String get weakPassword => _isAr
      ? 'كلمة المرور ضعيفة جداً. يجب أن تحتوي على 6 أحرف على الأقل.'
      : 'Password is too weak. Must be at least 6 characters.';

  static String weakPasswordWithReasons(List<String> reasons) => _isAr
      ? 'كلمة المرور ضعيفة جداً:\n${reasons.map((r) => '• $r').join('\n')}'
      : 'Password is too weak:\n${reasons.map((r) => '• $r').join('\n')}';

  static String get invalidEmail => _isAr
      ? 'صيغة البريد الإلكتروني غير صالحة.'
      : 'Invalid email format.';

  static String get emailNotVerified => _isAr
      ? 'البريد الإلكتروني غير مفعل. يرجى التحقق من بريدك الإلكتروني.'
      : 'Email is not verified. Please check your inbox.';

  static String get invitationNotFound => _isAr
      ? 'الدعوة غير موجودة أو منتهية الصلاحية.'
      : 'Invitation not found or has expired.';

  static String get notAuthenticated => _isAr
      ? 'يجب تسجيل الدخول أولاً.'
      : 'You must log in first.';

  static String get googleSignInFailed => _isAr
      ? 'فشل تسجيل الدخول بحساب Google.'
      : 'Google Sign-In failed.';

  static String get appleSignInFailed => _isAr
      ? 'فشل تسجيل الدخول بحساب Apple.'
      : 'Apple Sign-In failed.';

  // Database / Query Failures
  static String get uniqueViolation => _isAr
      ? 'هذا السجل موجود مسبقاً.'
      : 'This record already exists.';

  static String get foreignKeyViolation => _isAr
      ? 'بيانات مرجعية غير موجودة.'
      : 'Referenced data does not exist.';

  static String get notNullViolation => _isAr
      ? 'حقل مطلوب لا يمكن أن يكون فارغاً.'
      : 'A required field cannot be empty.';

  static String get checkConstraintViolation => _isAr
      ? 'البيانات المدخلة تخالف شروط الصحة المحددة.'
      : 'Input data violates validation constraints.';

  static String get undefinedTable => _isAr
      ? 'خطأ في قاعدة البيانات: الجدول غير موجود.'
      : 'Database error: Table not found.';

  static String get undefinedColumn => _isAr
      ? 'خطأ في قاعدة البيانات: العمود غير موجود.'
      : 'Database error: Column not found.';

  static String get insufficientPrivileges => _isAr
      ? 'ليس لديك الصلاحية الكافية لإتمام هذا الإجراء.'
      : 'Insufficient privileges to perform this action.';

  static String get syntaxError => _isAr
      ? 'خطأ في صياغة استعلام قاعدة البيانات.'
      : 'Database query syntax error.';

  static String get stringDataRightTruncation => _isAr
      ? 'النص المدخل أطول من الحد المسموح به للحقل.'
      : 'Input text exceeds maximum allowed length.';

  static String get invalidDateTimeFormat => _isAr
      ? 'صيغة التاريخ أو الوقت غير صحيحة.'
      : 'Invalid date or time format.';

  static String get tooManyConnections => _isAr
      ? 'الخادم مشغول حالياً بسبب كثرة الاتصالات. أعد المحاولة لاحقاً.'
      : 'Server is busy due to high connection volume. Please retry later.';

  static String get ambiguousEmbed => _isAr
      ? 'خطأ في ربط الجداول: توجد علاقات متعددة متضاربة.'
      : 'Ambiguous table relationship error.';

  static String get queryTimeout => _isAr
      ? 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.'
      : 'Server connection timed out. Please try again.';

  static String get networkQuery => _isAr
      ? 'عفواً، لا يوجد اتصال بالإنترنت. تحقق من الشبكة وأعد المحاولة.'
      : 'No internet connection. Please verify your network and retry.';

  static String get formatQuery => _isAr
      ? 'حدث خطأ في معالجة أو تنسيق البيانات إرجاعاً.'
      : 'Error formatting or parsing response data.';

  static String get recordNotFound => _isAr
      ? 'لم يتم العثور على السجل المطلوب.'
      : 'Requested record was not found.';

  static String get invalidUuid => _isAr
      ? 'المعرف الممرر غير صالح (UUID غير صحيح).'
      : 'Invalid identifier (invalid UUID).';

  static String get jwtExpired => _isAr
      ? 'انتهت جلسة تسجيل الدخول. يرجى إعادة تسجيل الدخول.'
      : 'Session expired. Please log in again.';

  static String get unauthorizedApi => _isAr
      ? 'غير مصرح لك بالوصول إلى هذا المورد.'
      : 'Unauthorized access to this resource.';

  static String get planLimitReached => _isAr
      ? 'لقد وصلت للحد الأقصى المسموح به في خطتك الحالية'
      : 'You have reached the maximum limit allowed in your current plan.';

  static String get featureNotAllowed => _isAr
      ? 'الميزة غير متاحة في باقة اشتراكك الحالية'
      : 'Feature not included in your current subscription plan.';

  // Storage Failures
  static String get fileNotFound => _isAr
      ? 'الملف غير موجود.'
      : 'File not found.';

  static String get fileAlreadyExists => _isAr
      ? 'الملف موجود مسبقاً.'
      : 'File already exists.';

  static String get fileTooLarge => _isAr
      ? 'حجم الملف كبير جداً.'
      : 'File size is too large.';

  static String get invalidFile => _isAr
      ? 'نوع الملف غير مدعوم.'
      : 'Unsupported file type.';

  // Realtime Failures
  static String get realtimeChannelError => _isAr
      ? 'خطأ في قناة الاتصال المباشر.'
      : 'Realtime channel error.';

  static String get realtimeTimedOut => _isAr
      ? 'انتهت مهلة الاتصال المباشر.'
      : 'Realtime connection timed out.';

  static String get realtimeConnectionClosed => _isAr
      ? 'تم إغلاق الاتصال المباشر.'
      : 'Realtime connection was closed.';

  static String get realtimeUnexpected => _isAr
      ? 'خطأ غير متوقع في الاتصال المباشر.'
      : 'Unexpected realtime connection error.';

  // Appointment Validation Failures
  static String get patientIdRequired => _isAr
      ? 'معرف المريض مطلوب لإضافة موعد'
      : 'Patient ID is required to add an appointment';

  static String get doctorIdRequired => _isAr
      ? 'معرف الطبيب مطلوب لإضافة موعد'
      : 'Doctor ID is required to add an appointment';

  static String get typeIdRequired => _isAr
      ? 'نوع الموعد مطلوب لإضافة موعد'
      : 'Appointment type is required to add an appointment';

  static String get dateRequired => _isAr
      ? 'تاريخ الموعد مطلوب لإضافة موعد'
      : 'Appointment date is required to add an appointment';

  static String get appointmentIdRequired => _isAr
      ? 'معرف الموعد مطلوب لتعديله'
      : 'Appointment ID is required to update it';

  // Patient Validation Failures
  static String get patientNameRequired => _isAr
      ? 'اسم المريض مطلوب ولا يقل عن حرفين'
      : 'Patient name is required (at least 2 characters)';

  static String get patientGenderRequired => _isAr
      ? 'الجنس مطلوب لإضافة مريض'
      : 'Gender is required to add a patient';

  static String get dobMustBeInPast => _isAr
      ? 'تاريخ الميلاد يجب أن يكون في الماضي'
      : 'Date of birth must be in the past';

  static String get patientPlanLimitReached => _isAr
      ? 'لقد وصلت للحد الأقصى المسموح به من المرضى في خطتك الحالية'
      : 'You have reached the maximum allowed patients in your current plan';

  // Invoice Validation Failures
  static String get selectPatientRequired => _isAr
      ? 'يرجى اختيار المريض'
      : 'Please select a patient';

  static String get selectSourceAppointmentRequired => _isAr
      ? 'يرجى اختيار الموعد المرتبط بالفاتورة'
      : 'Please select the associated appointment';

  static String get totalAmountMustBePositive => _isAr
      ? 'يجب أن يكون المبلغ الإجمالي أكبر من الصفر'
      : 'Total amount must be greater than zero';

  static String get paidAmountCannotBeNegative => _isAr
      ? 'المبلغ المدفوع لا يمكن أن يكون بالسالب'
      : 'Paid amount cannot be negative';

  static String get paidCannotExceedTotal => _isAr
      ? 'المبلغ المدفوع لا يمكن أن يتجاوز المبلغ الإجمالي'
      : 'Paid amount cannot exceed total amount';

  static String get invalidInvoiceId => _isAr
      ? 'رقم الفاتورة غير صحيح'
      : 'Invalid invoice ID';

  // Prescription & Drug Validation Failures
  static String get drugTradeNameRequired => _isAr
      ? 'اسم الدواء التجاري مطلوب'
      : 'Drug trade name is required';

  static String get atLeastOneDrugRequired => _isAr
      ? 'يجب إضافة دواء واحد على الأقل للروشتة'
      : 'At least one medication is required in the prescription';

  static String get frequencyAndDurationRequired => _isAr
      ? 'يرجى تحديد الجرعة والمدة لجميع الأدوية'
      : 'Please specify frequency and duration for all medications';

  static String get doseTimingRequired => _isAr
      ? 'يرجى تحديد توقيت تناول الجرعة لجميع الأدوية'
      : 'Please specify dose timing for all medications';

  static String get templateNameRequired => _isAr
      ? 'اسم القالب مطلوب'
      : 'Template name is required';

  // Staff & Invitations Failures
  static String get staffPlanLimitReached => _isAr
      ? 'لقد وصلت للحد الأقصى المسموح به من الموظفين والدعوات في خطتك الحالية'
      : 'You have reached the maximum allowed staff and invitations in your current plan';
}
