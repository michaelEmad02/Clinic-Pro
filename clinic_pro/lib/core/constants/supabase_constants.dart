// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على ثوابت قواعد البيانات الخاصة بـ Supabase
// يشمل أسماء الجداول وقيم الحالات المختلفة (Statuses)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';

class SupabaseTables {
  static const String owners = 'Owners';
  static const String clinics = 'clinics';
  static const String users = 'users';
  static const String clinicStaff = 'clinic_staff';
  static const String patients = 'patients';
  static const String prescriptionTemplates = 'prescription_templates';
  static const String prescriptionTemplateItems = 'prescription_template_items';
  static const String appointmentTypes = 'appointment_types';
  static const String doctorAppointmentTypes = 'doctor_appointment_types';
  static const String appointments = 'appointments';
  static const String doctorQueueRules = 'doctor_queue_rules';
  static const String prescriptions = 'prescriptions';
  static const String prescriptionItems = 'prescription_items';
  static const String prescriptionDocs = 'prescription_docs';
  static const String invoices = 'invoices';
  static const String expenses = 'expenses';
  static const String subscriptions = 'subscriptions';
  static const String invitations = 'invitations';
  static const String doctorSecretaries = 'doctor_secretary_schedule';
  static const String doctorSchedules = 'doctor_schedules';
  static const String drugs = 'drugs';
  static const String plans = 'plans';
  static const String plansFeatures = 'plans_features';
}

class SupabaseBucket {
  static const String usersAvatar = 'users_avatar';
  static const String clinicLogos = 'clinics';
  static const String attachments = 'attachments';
  static const String pdfs = 'pdfs';
}

class AppointmentStatus {
  static const String scheduled = 'scheduled'; // حجز مجدول
  static const String confirmed =
      'confirmed'; // تأكيد الحضور (دخل قائمة الانتظار)
  static const String inProgress =
      'in_progress'; // الكشف جارٍ حالياً عند الطبيب
  static const String done = 'done'; // تم الانتهاء من الكشف وحفظ الروشتة
  static const String cancelled = 'cancelled'; // حجز ملغى
}

class InvitationStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String cancelled = 'cancelled';
  static const String expired = 'expired';
}

class QueueSlotType {
  static const String normal = 'normal'; // كشف عادي
  static const String urgent = 'urgent'; // كشف مستعجل (حالة طارئة)
  static const String revisit = 'revisit'; // إعادة كشف
  static const String consult = 'consult'; // استشارة مجانية
}

class DoctorQueueSystem {
  static const String arrival = 'arrival';
  static const String booking = 'booking';
  static const String pattern = 'pattern';
  static const String scheduled = 'scheduled';
}

class StaffRole {
  static String owner = StaffRoles.owner.name; // مالك العيادة
  static String doctor = StaffRoles.doctor.name; // طبيب
  static String secretary = StaffRoles.secretary.name; // سكرتارية
}

class SubscriptionType {
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
  static const String lifetime = 'lifetime';
  static const String trail = 'trail';
}

class SubscriptionStatus {
  static const String pending = 'pending';
  static const String active = 'active';
  static const String trial = 'cancelled';
  static const String expired = 'expired';
}
