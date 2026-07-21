import 'package:clinic_pro/features/staff_and_invitations/domain/entities/doctor_schedules_entity.dart';
import 'package:flutter/material.dart';

class DoctorSchedulesModel extends DoctorSchedulesEntity {
  DoctorSchedulesModel({
    required super.id,
    required super.clinicId,
    required super.doctorId,
    required super.dayOfWeek,
    required super.isActive,
    super.endTime,
    super.startTime,
  });

  static TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  static String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory DoctorSchedulesModel.fromJson(Map<String, dynamic> json) {
    return DoctorSchedulesModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      doctorId: json['doctor_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      isActive: json['is_active'] as bool,
      endTime: _parseTimeOfDay(json['end_time'] as String?),
      startTime: _parseTimeOfDay(json['start_time'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "clinic_id": clinicId,
      "doctor_id": doctorId,
      "is_active": isActive,
      "day_of_week": dayOfWeek,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
    };
  }
}
