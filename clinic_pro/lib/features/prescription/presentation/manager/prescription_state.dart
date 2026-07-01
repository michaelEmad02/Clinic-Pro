import 'package:equatable/equatable.dart';

// ────────────────────────────────────────────────────────
// نموذج الدواء المختار للروشتة
// ────────────────────────────────────────────────────────
class SelectedDrugModel extends Equatable {
  final String id;
  final String tradeName;
  final String genericName;
  final String category;
  final int? doseFrequency;
  final int? doseDuration;
  final String? doseTiming;
  final bool isPrn;

  const SelectedDrugModel({
    required this.id,
    required this.tradeName,
    required this.genericName,
    required this.category,
    required this.doseFrequency,
    required this.doseDuration,
    required this.doseTiming,
    required this.isPrn,
  });

  SelectedDrugModel copyWith({
    int? doseFrequency,
    int? doseDuration,
    String? doseTiming,
    bool? isPrn,
  }) {
    return SelectedDrugModel(
      id: id,
      tradeName: tradeName,
      genericName: genericName,
      category: category,
      doseFrequency: doseFrequency ?? this.doseFrequency,
      doseDuration: doseDuration ?? this.doseDuration,
      doseTiming: doseTiming ?? this.doseTiming,
      isPrn: isPrn ?? this.isPrn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tradeName,
        genericName,
        category,
        doseFrequency,
        doseDuration,
        doseTiming,
        isPrn,
      ];
}

// ────────────────────────────────────────────────────────
// حالات إدارة شاشة الروشتة
// ────────────────────────────────────────────────────────
enum PrescriptionStatus { initial, loading, loaded, success, error }

class PrescriptionState extends Equatable {
  final PrescriptionStatus status;
  final String appointmentId;
  final String clinicId;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String bloodType;
  final String visitType;
  final String doctorName;
  final String visitDate;
  final List<String> selectedDiagnosis;
  final List<SelectedDrugModel> selectedDrugs;
  final String finalDiagnosis;
  final String notes;
  final String? errorMessage;

  const PrescriptionState({
    this.status = PrescriptionStatus.initial,
    this.appointmentId = '',
    this.clinicId = '',
    this.patientName = '',
    this.patientAge = '',
    this.patientGender = '',
    this.bloodType = '',
    this.visitType = '',
    this.doctorName = '',
    this.visitDate = '',
    this.selectedDiagnosis = const [],
    this.selectedDrugs = const [],
    this.finalDiagnosis = '',
    this.notes = '',
    this.errorMessage,
  });

  PrescriptionState copyWith({
    PrescriptionStatus? status,
    String? appointmentId,
    String? clinicId,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? bloodType,
    String? visitType,
    String? doctorName,
    String? visitDate,
    List<String>? selectedDiagnosis,
    List<SelectedDrugModel>? selectedDrugs,
    String? finalDiagnosis,
    String? notes,
    String? errorMessage,
  }) {
    return PrescriptionState(
      status: status ?? this.status,
      appointmentId: appointmentId ?? this.appointmentId,
      clinicId: clinicId ?? this.clinicId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      bloodType: bloodType ?? this.bloodType,
      visitType: visitType ?? this.visitType,
      doctorName: doctorName ?? this.doctorName,
      visitDate: visitDate ?? this.visitDate,
      selectedDiagnosis: selectedDiagnosis ?? this.selectedDiagnosis,
      selectedDrugs: selectedDrugs ?? this.selectedDrugs,
      finalDiagnosis: finalDiagnosis ?? this.finalDiagnosis,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        appointmentId,
        clinicId,
        patientName,
        patientAge,
        patientGender,
        bloodType,
        visitType,
        doctorName,
        visitDate,
        selectedDiagnosis,
        selectedDrugs,
        finalDiagnosis,
        notes,
        errorMessage,
      ];
}
