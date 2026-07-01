import 'package:equatable/equatable.dart';


abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrescriptionDataEvent extends PrescriptionEvent {
  final String appointmentId;

  const LoadPrescriptionDataEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

class ToggleDiagnosisEvent extends PrescriptionEvent {
  final String diagnosis;

  const ToggleDiagnosisEvent(this.diagnosis);

  @override
  List<Object?> get props => [diagnosis];
}

class AddCustomDiagnosisEvent extends PrescriptionEvent {
  final String diagnosis;

  const AddCustomDiagnosisEvent(this.diagnosis);

  @override
  List<Object?> get props => [diagnosis];
}

class AddDrugToPrescriptionEvent extends PrescriptionEvent {
  final Map<String, dynamic> drug;

  const AddDrugToPrescriptionEvent(this.drug);

  @override
  List<Object?> get props => [drug];
}

class RemoveDrugFromPrescriptionEvent extends PrescriptionEvent {
  final String drugId;

  const RemoveDrugFromPrescriptionEvent(this.drugId);

  @override
  List<Object?> get props => [drugId];
}

class UpdateDrugDoseEvent extends PrescriptionEvent {
  final String drugId;
  final int? doseFrequency;
  final int? doseDuration;
  final String? doseTiming;
  final bool? isPrn;

  const UpdateDrugDoseEvent({
    required this.drugId,
    this.doseFrequency,
    this.doseDuration,
    this.doseTiming,
    this.isPrn,
  });

  @override
  List<Object?> get props => [
        drugId,
        doseFrequency,
        doseDuration,
        doseTiming,
        isPrn,
      ];
}

class ApplyTemplateEvent extends PrescriptionEvent {
  final String templateId;

  const ApplyTemplateEvent(this.templateId);

  @override
  List<Object?> get props => [templateId];
}

class UpdatePrescriptionFieldsEvent extends PrescriptionEvent {
  final String? finalDiagnosis;
  final String? notes;

  const UpdatePrescriptionFieldsEvent({this.finalDiagnosis, this.notes});

  @override
  List<Object?> get props => [finalDiagnosis, notes];
}

class SavePrescriptionEvent extends PrescriptionEvent {
  const SavePrescriptionEvent();
}

class CopyPreviousPrescriptionEvent extends PrescriptionEvent {
  const CopyPreviousPrescriptionEvent();
}
