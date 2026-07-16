// ────────────────────────────────────────────────────────
// نموذج كيان الدعوة (InvitationModel)
// يرث من InvitationEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';

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
    StaffRoles roleType;
    final roleStr = json['role'] as String? ?? 'doctor';
    if (roleStr == 'secretary') {
      roleType = StaffRoles.secretary;
    } else if (roleStr == 'owner') {
      roleType = StaffRoles.owner;
    } else {
      roleType = StaffRoles.doctor;
    }
    var statusStr = json['status'] as String? ?? 'pending';

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
      'id': id,
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
}
