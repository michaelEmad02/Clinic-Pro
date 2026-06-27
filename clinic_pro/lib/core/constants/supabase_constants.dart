// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على ثوابت قواعد البيانات الخاصة بـ Supabase
// يشمل أسماء الجداول وقيم الحالات المختلفة (Statuses)
// ────────────────────────────────────────────────────────

class SupabaseTables {
  static const String owners = 'owners';
  static const String clinics = 'clinics';
  static const String users = 'users';
  static const String clinicStaff = 'clinic_staff';
  static const String patients = 'patients';
  static const String prescriptionTemplates = 'prescription_templates';
  static const String prescriptionTemplateItems = 'prescription_template_items';
  static const String appointmentTypes = 'appointment_types';
  static const String appointments = 'appointments';
  static const String doctorQueueRules = 'doctor_queue_rules';
  static const String prescriptions = 'prescriptions';
  static const String prescriptionItems = 'prescription_items';
  static const String prescriptionDocs = 'prescription_docs';
  static const String invoices = 'invoices';
  static const String expenses = 'expenses';
  static const String subscriptions = 'subscriptions';
}

class AppointmentStatus {
  static const String scheduled = 'scheduled'; // حجز مجدول
  static const String confirmed = 'confirmed'; // تأكيد الحضور (دخل قائمة الانتظار)
  static const String inProgress = 'in_progress'; // الكشف جارٍ حالياً عند الطبيب
  static const String done = 'done'; // تم الانتهاء من الكشف وحفظ الروشتة
  static const String cancelled = 'cancelled'; // حجز ملغى
}

class QueueSlotType {
  static const String normal = 'normal'; // كشف عادي
  static const String urgent = 'urgent'; // كشف مستعجل (حالة طارئة)
  static const String revisit = 'revisit'; // إعادة كشف
  static const String consult = 'consult'; // استشارة مجانية
}

class StaffRole {
  static const String owner = 'owner'; // مالك العيادة
  static const String doctor = 'doctor'; // طبيب
  static const String secretary = 'secretary'; // سكرتارية
}

class SubscriptionType {
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
  static const String lifetime = 'lifetime';
}

class SubscriptionStatus {
  static const String active = 'active';
  static const String trial = 'trial';
  static const String expired = 'expired';
}
