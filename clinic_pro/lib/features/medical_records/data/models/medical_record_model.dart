// ────────────────────────────────────────────────────────
// نموذج السجل الطبي (MedicalRecordModel)
// يرث من MedicalRecordEntity ويضيف التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/medical_record_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  const MedicalRecordModel({
    required super.id,
    required super.clinicId,
    required super.patientId,
    super.doctorId,
    super.appointmentId,
    super.appointmentTypeName,
    super.appointmentDate,
    super.prescriptionId,
    required super.type,
    required super.title,
    required super.fileUrl,
    required super.storagePath,
    required super.recordDate,
    super.notes,
    super.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String?,
      appointmentId: json['appointment_id'] as String?,
      appointmentTypeName: json['appointment_type_name'] as String?,
      appointmentDate: json['appointment_date'] as String?,
      prescriptionId: json['prescription_id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String,
      storagePath: json['storage_path'] as String,
      recordDate: json['record_date'] as String? ?? DateTime.now().toIso8601String().split('T').first,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_id': appointmentId,
      'prescription_id': prescriptionId,
      'type': type,
      'title': title,
      'file_url': fileUrl,
      'storage_path': storagePath,
      'record_date': recordDate,
      'notes': notes,
    };
  }
}
