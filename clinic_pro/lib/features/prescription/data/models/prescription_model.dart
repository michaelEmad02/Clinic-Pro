// ────────────────────────────────────────────────────────
// نماذج الروشتة الطبية (PrescriptionModel & Item)
// ────────────────────────────────────────────────────────

import '../../domain/entities/prescription_entity.dart';
import 'drug_model.dart';

class PrescriptionItemModel extends PrescriptionItemEntity {
  const PrescriptionItemModel({
    required super.id,
    required super.prescriptionId,
    super.drugId,
    super.frequency,
    super.duration,
    super.timing,
    super.isPrn = false,
    super.drug,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    int? parseNum(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    return PrescriptionItemModel(
      id: json['id'] as String,
      prescriptionId: json['prescription_id'] as String? ?? '',
      drugId: json['drug_id'] as String?,
      frequency: parseNum(json['frequency']),
      duration: parseNum(json['duration']),
      timing: json['timing'] as String?,
      isPrn: json['is_prn'] as bool? ?? false,
      drug: json['drugs'] != null
          ? DrugModel.fromJson(json['drugs'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'drug_id': drugId,
      'frequency': frequency,
      'duration': duration,
      'timing': timing,
      'is_prn': isPrn,
    };
  }
}

class PrescriptionModel extends PrescriptionEntity {
  const PrescriptionModel({
    required super.id,
    required super.createdAt,
    super.clinicId,
    super.doctorId,
    super.patientId,
    super.appointmentId,
    super.diagnosis,
    super.notes,
    super.items = const [],
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null ? json['created_at'].toString() : DateTime.now().toIso8601String(),
      clinicId: json['clinic_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      patientId: json['patient_id'] as String?,
      appointmentId: json['appointment_id'] as String?,
      diagnosis: json['notes'] is Map ? json['notes']['diagnoses']?.toString() : null,
      notes: json['notes'] is Map ? json['notes']['general_notes']?.toString() : null,
      items: json['prescription_items'] != null
          ? (json['prescription_items'] as List)
              .map((i) => PrescriptionItemModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'notes': {
        'diagnoses': diagnosis,
        'general_notes': notes,
      },
    };
  }
}
