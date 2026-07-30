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
    return PrescriptionItemModel(
      id: json['id'] as String,
      prescriptionId: json['prescription_id'] as String? ?? '',
      drugId: json['drug_id'] as String?,
      frequency: json['frequency'] as int?,
      duration: json['duration'] as int?,
      timing: json['timing'] as String?,
      isPrn: json['is_prn'] as bool? ?? false,
      drug: json['drugs'] != null
          ? DrugModel.fromJson(json['drugs'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    super.diagnosis,
    super.notes,
    super.items = const [],
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['prescription_items'] as List?;
    final itemsList = rawItems != null
        ? rawItems
            .map((e) => PrescriptionItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PrescriptionItemModel>[];

    return PrescriptionModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String? ?? '',
      clinicId: json['clinic_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      patientId: json['patient_id'] as String?,
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'diagnosis': diagnosis,
      'notes': notes,
    };
  }
}
