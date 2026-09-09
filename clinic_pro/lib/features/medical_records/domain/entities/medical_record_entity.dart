// ────────────────────────────────────────────────────────
// كيان السجل الطبي / الفحص (MedicalRecordEntity)
// يمثل تحليلاً طبياً أو فحص أشعة خاصاً بالمريض
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../../core/constants/supabase_constants.dart';

class MedicalRecordEntity extends Equatable {
  final String id;
  final String clinicId;
  final String patientId;
  final String? doctorId;
  final String? appointmentId;
  final String? appointmentTypeName; // اسم نوع الموعد (مثل: كشف، استشارة، فحص)
  final String? appointmentDate; // تاريخ الموعد المرتبط
  final String? prescriptionId;
  final String type; // lab_test أو radiology
  final String title;
  final String fileUrl;
  final String storagePath;
  final String recordDate;
  final String? notes;
  final String? createdAt;

  const MedicalRecordEntity({
    required this.id,
    required this.clinicId,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    this.appointmentTypeName,
    this.appointmentDate,
    this.prescriptionId,
    required this.type,
    required this.title,
    required this.fileUrl,
    required this.storagePath,
    required this.recordDate,
    this.notes,
    this.createdAt,
  });

  bool get isLabTest => type == MedicalRecordType.labTest;
  bool get isRadiology => type == MedicalRecordType.radiology;

  String get typeLabel => MedicalRecordType.toLocalized(type);

  /// هل الفحص مرتبط بموعد محدد أم فحص مستقل
  bool get isLinkedToAppointment =>
      appointmentId != null && appointmentId!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        clinicId,
        patientId,
        doctorId,
        appointmentId,
        appointmentTypeName,
        appointmentDate,
        prescriptionId,
        type,
        title,
        fileUrl,
        storagePath,
        recordDate,
        notes,
        createdAt,
      ];
}
