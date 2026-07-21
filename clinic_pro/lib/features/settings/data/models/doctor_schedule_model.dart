// ────────────────────────────────────────────────────────
// نموذج مواعيد عمل الطبيب (DoctorScheduleModel)
// يرث من DoctorScheduleEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/doctor_schedule_entity.dart';

class DoctorScheduleModel extends DoctorScheduleEntity {
  const DoctorScheduleModel({
    required super.id,
    required super.doctorId,
    required super.clinicId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      clinicId: json['clinic_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String? ?? '09:00',
      endTime: json['end_time'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'clinic_id': clinicId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
