// ────────────────────────────────────────────────────────
// كيان تحميل بيانات الروشتة (PrescriptionLoadDataEntity)
// يحتوي على المعلومات المجمعة لعرضها في شاشة الروشتة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'prescription_entity.dart';

class PrescriptionLoadDataEntity extends Equatable {
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String patientGender;
  final String patientBirthDate;
  final String bloodType;
  final String clinicId;
  final String visitType;
  final String doctorName;
  final String visitDate;
  final List<String> selectedDiagnosis;
  final List<PrescriptionItemEntity> selectedDrugs;
  final String finalDiagnosis;
  final String notes;
  final int? nextVisitDays;
  final String? prescriptionId; // معرف الروشتة الحالية (إن وجد للتعديل)

  const PrescriptionLoadDataEntity({
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.patientGender,
    required this.patientBirthDate,
    required this.bloodType,
    required this.clinicId,
    required this.visitType,
    required this.doctorName,
    required this.visitDate,
    required this.selectedDiagnosis,
    required this.selectedDrugs,
    required this.finalDiagnosis,
    required this.notes,
    this.nextVisitDays,
    this.prescriptionId,
  });

  @override
  List<Object?> get props => [
        appointmentId,
        patientId,
        patientName,
        patientGender,
        patientBirthDate,
        bloodType,
        clinicId,
        visitType,
        doctorName,
        visitDate,
        selectedDiagnosis,
        selectedDrugs,
        finalDiagnosis,
        notes,
        nextVisitDays,
        prescriptionId,
      ];
}
