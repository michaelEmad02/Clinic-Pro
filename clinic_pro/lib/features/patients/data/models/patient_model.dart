// ────────────────────────────────────────────────────────
// نموذج المريض (PatientModel)
// يرث من PatientEntity ويقوم بعمليات التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.clinicId,
    required super.name,
    super.phone,
    super.address,
    super.dateOfBirth,
    super.allergies,
    super.chronicConditions,
    required super.gender,
    super.bloodType,
  });

  /// تحويل البيانات الخام من قاعدة البيانات إلى PatientModel
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String? ?? '',
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      allergies: json['allergies'] as String?,
      chronicConditions: json['chronic_conditions'] as String?,
      gender: json['gender'] as String? ?? 'male',
      bloodType: json['blood_type'] as String?,
    );
  }

  /// تحويل الكيان إلى Map لإرساله لقاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'name': name,
      'phone': phone,
      'address': address,
      'date_of_birth': dateOfBirth,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'gender': gender,
      'blood_type': bloodType,
    };
  }

  /// تحويل الكيان إلى Map لعملية التحديث (بدون clinic_id)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'date_of_birth': dateOfBirth,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'gender': gender,
      'blood_type': bloodType,
    };
  }

  /// إنشاء PatientModel من PatientEntity
  factory PatientModel.fromEntity(PatientEntity entity) {
    return PatientModel(
      id: entity.id,
      clinicId: entity.clinicId,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      dateOfBirth: entity.dateOfBirth,
      allergies: entity.allergies,
      chronicConditions: entity.chronicConditions,
      gender: entity.gender,
      bloodType: entity.bloodType,
    );
  }
}
