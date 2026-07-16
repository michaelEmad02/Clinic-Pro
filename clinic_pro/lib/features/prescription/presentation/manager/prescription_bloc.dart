import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';
import 'prescription_repository.dart';

@injectable
class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final PrescriptionRepository _repository;

  PrescriptionBloc(ICloudService cloudService)
      : _repository = PrescriptionRepository(cloudService),
        super(const PrescriptionState()) {
    on<LoadPrescriptionDataEvent>(_onLoad);
    on<ToggleDiagnosisEvent>(_onToggleDiagnosis);
    on<AddCustomDiagnosisEvent>(_onAddCustomDiagnosis);
    on<AddDrugToPrescriptionEvent>(_onAddDrug);
    on<RemoveDrugFromPrescriptionEvent>(_onRemoveDrug);
    on<UpdateDrugDoseEvent>(_onUpdateDrugDose);
    on<UpdatePrescriptionFieldsEvent>(_onUpdateFields);
    on<SavePrescriptionEvent>(_onSave);
    on<CopyPreviousPrescriptionEvent>(_onCopyPrevious);
    on<ApplyTemplateEvent>(_onApplyTemplate);
  }

  Future<void> _onLoad(
    LoadPrescriptionDataEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(state.copyWith(status: PrescriptionStatus.loading));

    try {
      final result = await _repository.loadData(event.appointmentId);

      final birthDateStr = result.patientRaw['birth_date'] as String? ?? '1990-01-01';
      final birthYear = int.tryParse(birthDateStr.substring(0, 4)) ?? 1990;
      final age = DateTime.now().year - birthYear;

      emit(state.copyWith(
        status: PrescriptionStatus.loaded,
        appointmentId: event.appointmentId,
        clinicId: result.appointmentRaw['clinic_id'] as String? ?? '',
        patientName: result.patientRaw['name'] as String? ?? AppStrings.unknownPatient,
        patientAge: '$age سنة',
        patientGender: (result.patientRaw['gender'] as String? ?? 'male') == 'male' ? AppStrings.male : AppStrings.female,
        bloodType: result.patientRaw['blood_type'] as String? ?? 'O+',
        visitType: result.typeName,
        doctorName: result.doctor['name'] as String? ?? AppStrings.generalPractitioner,
        visitDate: result.appointmentRaw['date'] as String? ??
            DateTime.now().toIso8601String().substring(0, 10),
        selectedDiagnosis: result.selectedDiagnosis,
        selectedDrugs: result.selectedDrugs,
        finalDiagnosis: result.finalDiagnosis,
        notes: result.notes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: AppStrings.loadFailed,
      ));
    }
  }

  void _onToggleDiagnosis(
    ToggleDiagnosisEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    final list = List<String>.from(state.selectedDiagnosis);
    if (list.contains(event.diagnosis)) {
      list.remove(event.diagnosis);
    } else {
      list.add(event.diagnosis);
    }
    emit(state.copyWith(selectedDiagnosis: list));
  }

  void _onAddCustomDiagnosis(
    AddCustomDiagnosisEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    if (event.diagnosis.trim().isEmpty) return;
    final list = List<String>.from(state.selectedDiagnosis);
    if (!list.contains(event.diagnosis)) {
      list.add(event.diagnosis);
    }
    emit(state.copyWith(selectedDiagnosis: list));
  }

  void _onAddDrug(
    AddDrugToPrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    final drugRaw = event.drug;
    final drugId = drugRaw['id'] as String;

    if (state.selectedDrugs.any((d) => d.id == drugId)) return;

    final newDrug = SelectedDrugModel(
      id: drugId,
      tradeName: drugRaw['trade_name'] as String? ?? '',
      genericName: drugRaw['generic_name'] as String? ?? '',
      category: drugRaw['category'] as String? ?? '',
      doseFrequency: 2,
      doseDuration: 7,
      doseTiming: 'after_meal',
      isPrn: false,
    );

    emit(state.copyWith(
      selectedDrugs: [...state.selectedDrugs, newDrug],
    ));
  }

  void _onRemoveDrug(
    RemoveDrugFromPrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    final list = state.selectedDrugs.where((d) => d.id != event.drugId).toList();
    emit(state.copyWith(selectedDrugs: list));
  }

  void _onUpdateDrugDose(
    UpdateDrugDoseEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    final list = state.selectedDrugs.map((d) {
      if (d.id == event.drugId) {
        return d.copyWith(
          doseFrequency: event.doseFrequency,
          doseDuration: event.doseDuration,
          doseTiming: event.doseTiming,
          isPrn: event.isPrn,
        );
      }
      return d;
    }).toList();

    emit(state.copyWith(selectedDrugs: list));
  }

  void _onUpdateFields(
    UpdatePrescriptionFieldsEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    emit(state.copyWith(
      finalDiagnosis: event.finalDiagnosis ?? state.finalDiagnosis,
      notes: event.notes ?? state.notes,
    ));
  }

  Future<void> _onSave(
    SavePrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    if (state.selectedDiagnosis.isEmpty && state.finalDiagnosis.trim().isEmpty) {
      emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: '${AppStrings.add} ${AppStrings.medicalDiagnosis}',
      ));
      return;
    }
    if (state.selectedDrugs.isEmpty) {
      emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: '${AppStrings.add} ${AppStrings.drug}',
      ));
      return;
    }
    for (final drug in state.selectedDrugs) {
      if (!drug.isPrn && (drug.doseFrequency == null || drug.doseDuration == null)) {
        emit(state.copyWith(
          status: PrescriptionStatus.error,
           errorMessage: '${AppStrings.dosage} ${AppStrings.frequency} ${drug.tradeName}',
        ));
        return;
      }
      if (drug.doseTiming == null) {
        emit(state.copyWith(
          status: PrescriptionStatus.error,
           errorMessage: '${AppStrings.timing} ${drug.tradeName}',
        ));
        return;
      }
    }

    emit(state.copyWith(status: PrescriptionStatus.loading));

    try {
      await _repository.save(state);
      emit(state.copyWith(status: PrescriptionStatus.success));
    } catch (_) {
      emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: AppStrings.error,
      ));
    }
  }

  Future<void> _onCopyPrevious(
    CopyPreviousPrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    try {
      final (copiedDrugs, diags) = await _repository.copyPrevious();

      if (copiedDrugs.isEmpty) {
        emit(state.copyWith(
          errorMessage: '${AppStrings.noData} ${AppStrings.prescription}',
        ));
        return;
      }

      emit(state.copyWith(
        selectedDiagnosis: diags,
        selectedDrugs: copiedDrugs,
      ));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: '${AppStrings.noData} ${AppStrings.prescription}',
      ));
    }
  }

  Future<void> _onApplyTemplate(
    ApplyTemplateEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    try {
      final (templateItems, templateName) =
          await _repository.getTemplateData(event.templateId);

      final updatedDrugs = List<SelectedDrugModel>.from(state.selectedDrugs);
      for (final item in templateItems) {
        if (!updatedDrugs.any((d) => d.id == item.id)) {
          updatedDrugs.add(item);
        }
      }

      final updatedDiagnosis = List<String>.from(state.selectedDiagnosis);
      if (templateName.isNotEmpty && !updatedDiagnosis.contains(templateName)) {
        updatedDiagnosis.add(templateName);
      }

      emit(state.copyWith(
        selectedDrugs: updatedDrugs,
        selectedDiagnosis: updatedDiagnosis,
      ));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: '${AppStrings.error} ${AppStrings.template}',
      ));
    }
  }
}
