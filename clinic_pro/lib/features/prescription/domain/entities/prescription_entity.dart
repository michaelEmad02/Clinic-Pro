// ────────────────────────────────────────────────────────
// كيان الروشتة الطبية (PrescriptionEntity)
// يمثل الروشتة وعناصر الأدوية التي تم صرفها بها
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'drug_entity.dart';

class PrescriptionItemEntity extends Equatable {
  final String id;
  final String prescriptionId;
  final String? drugId;
  final int? frequency;
  final int? duration;
  final String? timing;
  final bool isPrn;
  final DrugEntity? drug;

  const PrescriptionItemEntity({
    required this.id,
    required this.prescriptionId,
    this.drugId,
    this.frequency,
    this.duration,
    this.timing,
    this.isPrn = false,
    this.drug,
  });

  @override
  List<Object?> get props => [
        id,
        prescriptionId,
        drugId,
        frequency,
        duration,
        timing,
        isPrn,
        drug,
      ];
}

class PrescriptionEntity extends Equatable {
  final String id;
  final String createdAt;
  final String? clinicId;
  final String? doctorId;
  final String? patientId;
  final String? appointmentId;
  final String? diagnosis;
  final List<String> diagnoses;
  final String? notes;
  final int? nextVisitDays;
  final String? patientName;
  final String? patientPhone;
  final List<PrescriptionItemEntity> items;

  const PrescriptionEntity({
    required this.id,
    required this.createdAt,
    this.clinicId,
    this.doctorId,
    this.patientId,
    this.appointmentId,
    this.patientName,
    this.patientPhone,
    this.diagnosis,
    this.diagnoses = const [],
    this.notes,
    this.nextVisitDays,
    this.items = const [],
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        clinicId,
        doctorId,
        patientId,
        appointmentId,
        patientName,
        patientPhone,
        diagnosis,
        diagnoses,
        notes,
        nextVisitDays,
        items,
      ];
}
