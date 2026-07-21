import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/doctor_schedules_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/doctor_secretaries_entity.dart';

class StaffEntity {
  final String id;
  final String clinicId;
  final String userId; // = user_id
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String? specialty;
  final List<DoctorSecretariesEntity>?
      doctorSecretaries; // if the staff (role )is secretary

  final List<DoctorSchedulesEntity>? doctorSchedules; // if the staff is doctor
  final StaffRoles role;
  final bool isActive;
  final DateTime joinedAt;

  StaffEntity({
    required this.id,
    required this.clinicId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.specialty,
    this.doctorSecretaries,
    this.doctorSchedules,
    required this.role,
    required this.isActive,
    required this.joinedAt,
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0];
    return '${parts.first[0]}${parts.last[0]}';
  }
}
