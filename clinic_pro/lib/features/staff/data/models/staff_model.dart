import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/staff/data/models/doctor_schedules_model.dart';
import 'package:clinic_pro/features/staff/data/models/doctor_secretaries_model.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';

class StaffModel extends StaffEntity {
  StaffModel({
    required super.id,
    required super.clinicId,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    super.avatarUrl,
    super.specialty,
    super.doctorSchedules,
    super.doctorSecretaries,
    required super.role,
    required super.isActive,
    required super.joinedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    // Robustly handle both flat JSON structure and nested 'users' join from Supabase
    final userMap = json['users'] as Map<String, dynamic>?;
    
    final name = json['name'] as String? ?? userMap?['name'] as String? ?? '';
    final email = json['email'] as String? ?? userMap?['email'] as String? ?? '';
    final phone = json['phone'] as String? ?? userMap?['phone'] as String? ?? '';
    final avatarUrl = json['avatar_url'] as String? ?? userMap?['avatar_url'] as String?;
    final specialty = json['specialty'] as String? ?? userMap?['specialty'] as String?;

    // Parse role enum safely
    final role = StaffRoles.fromString(
      json['role'] as String?,
      defaultRole: StaffRoles.secretary,
    );

    return StaffModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      userId: json['user_id'] as String,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      specialty: specialty,
      role: role,
      isActive: json['is_active'] as bool? ?? true,
      joinedAt: DateTime.parse(
        json['joined_at'] as String,
      ),
      doctorSchedules: (json['doctor_schedules'] as List?)
          ?.map((d) => DoctorSchedulesModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      doctorSecretaries: (json['doctor_secretaries'] as List?)
          ?.map((d) => DoctorSecretariesModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "clinic_id": clinicId,
      "user_id": userId,
      "role": role.name,
      "is_active": isActive,
      "joined_at": joinedAt.toIso8601String(),
      // "name": name,
      // "email": email,
      // "phone": phone,
      // "avatar_url": avatarUrl,
      // "specialty": specialty,
    };
  }
}
