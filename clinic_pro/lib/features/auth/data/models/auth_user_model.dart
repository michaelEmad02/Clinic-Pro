// ────────────────────────────────────────────────────────
// نموذج مستخدم المصادقة (AuthUserModel)
// يرث من AuthUserEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import '../../domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.address,
    super.email,
    required super.role,
    super.specialty,
    super.imageUrl,
    super.isActive,
    super.ownerId,
    super.country,
  });

  /// إنشاء نموذج من البيانات القادمة من قاعدة البيانات (Supabase Map)
  factory AuthUserModel.fromJson(Map<String, dynamic> json, StaffRoles role) {
    return AuthUserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      email: json['email'] as String?,
      role: role,
      specialty: json['specialty'] as String?,
      imageUrl: (json['image_url'] ?? json['avatar_url']) as String?,
      isActive: json['is_active'] as bool? ?? true,
      ownerId: json['owner_id'] as String?,
      country: json['country'] as String?,
    );
  }

  /// تحويل الكيان إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'specialty': specialty,
      'image_url': imageUrl,
      'is_active': isActive,
      'owner_id': ownerId,
      'country': country,
    };
  }
}
