// ────────────────────────────────────────────────────────
// UnpaidAppointmentModel — نموذج الموعد غير المفوتر
// يحول الخريطة الخام (JSON Map) إلى UnpaidAppointmentEntity
// ────────────────────────────────────────────────────────

import '../../domain/entities/unpaid_appointment_entity.dart';

class UnpaidAppointmentModel extends UnpaidAppointmentEntity {
  const UnpaidAppointmentModel({
    required super.id,
    required super.patientId,
    super.patientName,
    required super.clinicId,
    super.doctorId,
    super.doctorName,
    super.appointmentTypeName,
    required super.expectedPrice,
    super.paidSoFar = 0.0,
    required super.date,
    required super.time,
  });

  factory UnpaidAppointmentModel.fromJson(Map<String, dynamic> json) {
    return UnpaidAppointmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      clinicId: json['clinic_id'] as String? ?? '',
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String?,
      appointmentTypeName: json['appointment_type_name'] as String?,
      expectedPrice: (json['expected_price'] as num?)?.toDouble() ?? 0.0,
      paidSoFar: (json['paid_so_far'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'appointment_type_name': appointmentTypeName,
      'expected_price': expectedPrice,
      'paid_so_far': paidSoFar,
      'date': date,
      'time': time,
    };
  }
}
