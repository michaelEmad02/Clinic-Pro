// ────────────────────────────────────────────────────────
// نموذج كيان الدعوة (InvitationModel)
// يرث من InvitationEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/invitation_entity.dart';

class InvitationModel extends InvitationEntity {
  InvitationModel({
    required super.id,
    required super.ownerId,
    required super.clinicId,
    super.clinicName,
    super.doctorId,
    super.doctorName,
    required super.email,
    required super.name,
    required super.role,
    required super.token,
    required super.status,
    required super.expiredAt,
    required super.createdAt,
  });

  /// إنشاء نموذج من البيانات السحابية
  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    final roleType = StaffRoles.fromString(json['role'] as String?);
    var statusStr = json['status'] as String? ?? InvitationStatus.pending;

    return InvitationModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      clinicName: json['clinic_name'] as String? ?? json['clinicName'] as String?,
      ownerId: json['owner_id'] as String,
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String? ?? json['doctorName'] as String?,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: roleType,
      token: json['token'] as String,
      status: statusStr,
      expiredAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل النموذج إلى Map لحفظه
  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'owner_id': ownerId,
      'doctor_id': doctorId,
      'email': email,
      'name': name,
      'role': role.name,
      'token': token,
      'status': status,
      'expires_at': expiredAt.toIso8601String(),
    };
  }

  /// دالة copyWith لنسخ الكائن مع إمكانية تعديل بعض الحقول
  InvitationModel copyWith({
    String? id,
    String? ownerId,
    String? clinicId,
    String? clinicName,
    String? doctorId,
    String? doctorName,
    String? email,
    String? name,
    StaffRoles? role,
    String? token,
    String? status,
    DateTime? expiredAt,
    DateTime? createdAt,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
      status: status ?? this.status,
      expiredAt: expiredAt ?? this.expiredAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
