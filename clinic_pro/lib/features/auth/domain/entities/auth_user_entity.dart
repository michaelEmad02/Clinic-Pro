// ────────────────────────────────────────────────────────
// ملف تعريف كيان المستخدم المصادق عليه (AuthUserEntity)
// يمثل هذا الكيان المالك أو الطبيب أو السكرتير بعد تسجيل الدخول
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';

class AuthUserEntity {
  final String id; // المعرف الفريد للمستخدم (المطابق لـ auth.uid() في Supabase)
  final String name; // الاسم الكامل للمستخدم
  final String phone; // رقم الهاتف
  final String address; // العنوان الشخصي أو عنوان العيادة
  final String? email; // البريد الإلكتروني للمستخدم (اختياري)
  final StaffRoles role; // دور المستخدم في النظام (owner, doctor, secretary)
  final String? specialty; // التخصص الطبي (للأطباء فقط)
  final String? imageUrl; // رابط الصورة الشخصية المخزنة
  final bool isActive; // حالة نشاط الحساب (نشط أم موقوف)
  final String? ownerId; // معرف المالك التابع له الموظف (للموظفين فقط)
  final String? country; // الدولة (لمالك العيادة فقط)

  const AuthUserEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.email,
    required this.role,
    this.specialty,
    this.imageUrl,
    this.isActive = true,
    this.ownerId,
    this.country,
  });

  AuthUserEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    StaffRoles? role,
    String? specialty,
    String? imageUrl,
    bool? isActive,
    String? ownerId,
    String? country,
  }) {
    return AuthUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      country: country ?? this.country,
    );
  }
}
