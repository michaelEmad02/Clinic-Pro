import 'package:clinic_pro/core/constants/staff_roles.dart';

class InvitationEntity {
  final String id; // المعرف الفريد للدعوة
  final String clinicId; // معرف العيادة المدعو إليها
  final String ownerId; // معرف مالك العيادة الذي أرسل الدعوة
  final String? doctorId; // معرف الطبيب اذا كانت الدعوة موجهة الي سكيرتير
  final String email; // البريد الإلكتروني المدعو
  final String? name; // الاسم المقترح للموظف المدعو
  final StaffRoles role; // الدور الوظيفي المدعو له (doctor, secretary)
  final String token; // رمز الدعوة الفريد المستخدم للتحقق والقبول
  final String status; // حالة الدعوة (pending, accepted, expired)
  final String? clinicName;
  final String? doctorName;
  final DateTime
      expiredAt; // = now() + interval '7 days' // تاريخ انتهاء صلاحية الدعوة// تاريخ انتهاء صلاحية الدعوة
  final DateTime createdAt;

  String get initial => name != null && name!.isNotEmpty ? name![0].toUpperCase() : '?';

  InvitationEntity({
    required this.id,
    required this.ownerId,
    required this.clinicId,
    this.clinicName,
    this.doctorId,
    this.doctorName,
    required this.email,
    required this.name,
    required this.role,
    required this.token,
    required this.status,
    required this.expiredAt,
    required this.createdAt,
  });
}
