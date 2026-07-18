import 'package:clinic_pro/features/staff/domain/entities/doctor_secretaries_entity.dart';

class DoctorSecretariesModel extends DoctorSecretariesEntity {
  DoctorSecretariesModel({
    required super.id,
    required super.clinicId,
    required super.doctorId,
    required super.secretaryId,
    required super.isActive,
  });

  factory DoctorSecretariesModel.fromJson(Map<String, dynamic> json) {
    return DoctorSecretariesModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      doctorId: json['doctor_id'] as String,
      secretaryId: json['secretary_id'] as String,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "clinic_id": clinicId,
      "doctor_id": doctorId,
      "secretary_id": secretaryId,
      "is_active": isActive,
    };
  }
}
