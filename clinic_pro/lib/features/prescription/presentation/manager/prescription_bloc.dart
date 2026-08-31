import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/usecases/copy_previous_prescription_usecase.dart';
import '../../domain/usecases/load_prescription_data_usecase.dart';
import '../../domain/usecases/save_prescription_usecase.dart';
import '../../domain/usecases/templates_usecases.dart';
import '../../domain/usecases/increment_template_usage_usecase.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';

@injectable
class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final LoadPrescriptionDataUseCase _loadPrescriptionDataUseCase;
  final SavePrescriptionUseCase _savePrescriptionUseCase;
  final CopyPreviousPrescriptionUseCase _copyPreviousPrescriptionUseCase;
  final GetTemplateDataUseCase _getTemplateDataUseCase;
  final IncrementTemplateUsageUseCase _incrementTemplateUsageUseCase;

  PrescriptionBloc(
    this._loadPrescriptionDataUseCase,
    this._savePrescriptionUseCase,
    this._copyPreviousPrescriptionUseCase,
    this._getTemplateDataUseCase,
    this._incrementTemplateUsageUseCase,
  ) : super(const PrescriptionState()) {
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
    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';
    final result =
        await _loadPrescriptionDataUseCase(event.appointment, doctorId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: failure.message,
      )),
      (data) {
        final birthDateStr = data.patientBirthDate;
        final birthYear = int.tryParse(birthDateStr.substring(0, 4)) ?? 1990;
        final age = DateTime.now().year - birthYear;

        final selectedDrugsList = data.selectedDrugs.map((e) {
          return SelectedDrugModel(
            id: e.drugId ?? '',
            tradeName: e.drug?.tradeName ?? '',
            genericName: e.drug?.genericName ?? '',
            category: e.drug?.category ?? '',
            doseFrequency: e.frequency,
            doseDuration: e.duration,
            doseTiming: e.timing,
            isPrn: e.isPrn,
          );
        }).toList();

        emit(state.copyWith(
          status: PrescriptionStatus.loaded,
          appointmentId: event.appointment.id,
          patientId: data.patientId,
          clinicId: data.clinicId,
          patientName: data.patientName,
          patientAge: '$age سنة',
          patientGender: data.patientGender == 'male'
              ? AppStrings.male
              : AppStrings.female,
          bloodType: data.bloodType,
          visitType: data.visitType,
          doctorName: data.doctorName,
          visitDate: data.visitDate,
          selectedDiagnosis: data.selectedDiagnosis,
          selectedDrugs: selectedDrugsList,
          finalDiagnosis: data.finalDiagnosis,
          notes: data.notes,
          nextVisitDays: data.nextVisitDays,
          prescriptionId: data.prescriptionId,
        ));
      },
    );
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
    final list =
        state.selectedDrugs.where((d) => d.id != event.drugId).toList();
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
      nextVisitDays: event.nextVisitDays,
      clearNextVisitDays: event.clearNextVisitDays,
    ));
  }

  Future<void> _onSave(
    SavePrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    // إذا ضغط المستخدم حفظ بدون إدخال أي بيانات، يتم الخروج من الشاشة دون حفظ روشتة فارغة
    if (state.selectedDrugs.isEmpty) {
      emit(state.copyWith(
          status: PrescriptionStatus.error,
          errorMessage: 'لا يمكن حفظ روشتة فارغة'));
      return;
    }

    // ─── أسماء القوالب المختارة (chips) ───
    final List<String> diagnosesList =
        List<String>.from(state.selectedDiagnosis);

    // ─── نص التشخيص الحر من الطبيب. لو فاضي → يأخذ أسماء القوالب كـ default ───
    final String diagnosisText = state.finalDiagnosis.trim().isNotEmpty
        ? state.finalDiagnosis.trim()
        : diagnosesList.join(' ، ');

    final items = state.selectedDrugs.map((d) {
      return PrescriptionItemEntity(
        id: '',
        prescriptionId: '',
        drugId: d.id,
        frequency: d.doseFrequency,
        duration: d.doseDuration,
        timing: d.doseTiming,
        isPrn: d.isPrn,
      );
    }).toList();

    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';

    final prescription = PrescriptionEntity(
      id: state.prescriptionId,
      clinicId: state.clinicId,
      doctorId: doctorId,
      patientId: state.patientId,
      appointmentId: state.appointmentId,
      diagnosis: diagnosisText,
      diagnoses: diagnosesList,
      notes: state.notes,
      nextVisitDays: state.nextVisitDays,
      createdAt: DateTime.now().toIso8601String(),
      items: items,
    );

    emit(state.copyWith(
      status: PrescriptionStatus.loading,
      postSaveAction: event.action,
    ));

    final result = await _savePrescriptionUseCase(prescription, doctorId);

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: failure.message,
      )),
      (_) async {
        for (final templateId in state.appliedTemplateIds) {
          try {
            await _incrementTemplateUsageUseCase(templateId);
          } catch (_) {}
        }
        emit(state.copyWith(
          status: PrescriptionStatus.success,
          postSaveAction: event.action,
          savedPrescription: prescription,
        ));
      },
    );
  }

  Future<void> _onCopyPrevious(
    CopyPreviousPrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    if (state.patientId.isEmpty) {
      emit(state.copyWith(
        errorMessage: '${AppStrings.noData} ${AppStrings.prescription}',
      ));
      return;
    }

    final result = await _copyPreviousPrescriptionUseCase(state.patientId);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (data) {
        final (copiedDrugs, diags) = data;

        if (copiedDrugs.isEmpty) {
          emit(state.copyWith(
            errorMessage: '${AppStrings.noData} ${AppStrings.prescription}',
          ));
          return;
        }

        final selectedDrugsList = copiedDrugs.map((e) {
          return SelectedDrugModel(
            id: e.drugId ?? '',
            tradeName: e.drug?.tradeName ?? '',
            genericName: e.drug?.genericName ?? '',
            category: e.drug?.category ?? '',
            doseFrequency: e.frequency,
            doseDuration: e.duration,
            doseTiming: e.timing,
            isPrn: e.isPrn,
          );
        }).toList();

        emit(state.copyWith(
          selectedDiagnosis: diags,
          selectedDrugs: selectedDrugsList,
        ));
      },
    );
  }

  Future<void> _onApplyTemplate(
    ApplyTemplateEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';
    final result = await _getTemplateDataUseCase(event.templateId, doctorId);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: failure.message,
      )),
      (data) {
        final (templateItems, templateName) = data;

        final updatedDrugs = List<SelectedDrugModel>.from(state.selectedDrugs);
        for (final item in templateItems) {
          if (!updatedDrugs.any((d) => d.id == item.drugId)) {
            updatedDrugs.add(SelectedDrugModel(
              id: item.drugId ?? '',
              tradeName: item.drug?.tradeName ?? '',
              genericName: item.drug?.genericName ?? '',
              category: item.drug?.category ?? '',
              doseFrequency: item.frequency,
              doseDuration: item.duration,
              doseTiming: item.timing,
              isPrn: item.isPrn,
            ));
          }
        }

        final updatedAppliedTemplates =
            List<String>.from(state.appliedTemplateIds);
        if (!updatedAppliedTemplates.contains(event.templateId)) {
          updatedAppliedTemplates.add(event.templateId);
        }

        final updatedDiagnosis = List<String>.from(state.selectedDiagnosis);
        if (templateName.isNotEmpty &&
            !updatedDiagnosis.contains(templateName)) {
          updatedDiagnosis.add(templateName);
        }
        emit(state.copyWith(
          selectedDrugs: updatedDrugs,
          selectedDiagnosis: updatedDiagnosis,
          appliedTemplateIds: updatedAppliedTemplates,
        ));
      },
    );
  }
}
