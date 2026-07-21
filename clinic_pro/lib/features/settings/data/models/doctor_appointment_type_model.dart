// ────────────────────────────────────────────────────────
// نموذج تسعيرة الزيارة (DoctorAppointmentTypeModel)
// يرث من DoctorAppointmentTypeEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/doctor_appointment_type_entity.dart';

class DoctorAppointmentTypeModel extends DoctorAppointmentTypeEntity {
  const DoctorAppointmentTypeModel({
    required super.id,
    required super.doctorId,
    super.clinicId,
    required super.appointmentTypeId,
    super.name,
    required super.price,
  });

  factory DoctorAppointmentTypeModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentTypeModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      clinicId: json['clinic_id'] as String?,
      appointmentTypeId: json['appointment_type_id'] as String,
      name: json['name'] as String?, // يُمكن جلبه بـ Join أو تعيينه يدوياً
      price: (json['price'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'clinic_id': clinicId,
      'appointment_type_id': appointmentTypeId,
      'price': price,
    };
  }
}
