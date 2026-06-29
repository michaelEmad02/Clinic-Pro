// ────────────────────────────────────────────────────────
// Bloc إدارة منطق شاشة الروشتة الطبية (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  PrescriptionBloc() : super(const PrescriptionState()) {
    on<LoadPrescriptionDataEvent>(_onLoad);
    on<ToggleDiagnosisEvent>(_onToggleDiagnosis);
    on<AddCustomDiagnosisEvent>(_onAddCustomDiagnosis);
    on<AddDrugToPrescriptionEvent>(_onAddDrug);
    on<RemoveDrugFromPrescriptionEvent>(_onRemoveDrug);
    on<UpdateDrugDoseEvent>(_onUpdateDrugDose);
    on<UpdatePrescriptionFieldsEvent>(_onUpdateFields);
    on<SavePrescriptionEvent>(_onSave);
    on<CopyPreviousPrescriptionEvent>(_onCopyPrevious);
  }

  Future<void> _onLoad(
    LoadPrescriptionDataEvent event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(state.copyWith(status: PrescriptionStatus.loading));
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // محاولة العثور على الموعد والبيانات المرتبطة به
      final apptRaw = MockData.appointments.firstWhere(
        (a) => a['id'] == event.appointmentId,
        orElse: () => MockData.appointments.first,
      );

      final patientId = apptRaw['patient_id'];
      final patientRaw = MockData.patients.firstWhere(
        (p) => p['id'] == patientId,
        orElse: () => MockData.patients.first,
      );

      final typeMap = apptRaw['appointment_types'] as Map<String, dynamic>? ?? {};
      final typeName = typeMap['name'] as String? ?? 'كشف عادي';

      final doctorId = apptRaw['doctor_id'] as String? ?? 'u-doc-1';
      final doctor = MockData.users.firstWhere(
        (u) => u['id'] == doctorId,
        orElse: () => {'name': 'د. أحمد يوسف'},
      );

      // حساب السن بناءً على تاريخ الميلاد أو استخدام قيمة ثابتة للمحاكاة
      final birthDateStr = patientRaw['birth_date'] as String? ?? '1990-01-01';
      final birthYear = int.tryParse(birthDateStr.substring(0, 4)) ?? 1990;
      final age = DateTime.now().year - birthYear;

      emit(state.copyWith(
        status: PrescriptionStatus.loaded,
        appointmentId: event.appointmentId,
        patientName: patientRaw['name'] as String? ?? 'مريض غير معروف',
        patientAge: '$age سنة',
        patientGender: (patientRaw['gender'] as String? ?? 'male') == 'male' ? 'ذكر' : 'أنثى',
        bloodType: patientRaw['blood_type'] as String? ?? 'O+',
        visitType: typeName,
        doctorName: doctor['name'] as String? ?? 'طبيب معالج',
        visitDate: '24 Oct, 2023', // تاريخ ثابت للمحاكاة
        selectedDiagnosis: [],
        selectedDrugs: [],
        finalDiagnosis: apptRaw['notes'] as String? ?? '',
        notes: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrescriptionStatus.error,
        errorMessage: 'تعذر تحميل بيانات الموعد',
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

    // التحقق من عدم تكرار الدواء
    if (state.selectedDrugs.any((d) => d.id == drugId)) return;

    final newDrug = SelectedDrugModel(
      id: drugId,
      tradeName: drugRaw['trade_name'] as String? ?? '',
      genericName: drugRaw['generic_name'] as String? ?? '',
      category: drugRaw['category'] as String? ?? '',
      form: drugRaw['form'] as String? ?? 'أقراص',
      doseOption: '١ قرص',
      doseFrequency: 'كل ١٢ ساعة',
      doseDuration: '٧ أيام',
      doseTiming: 'بعد الأكل',
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
          doseOption: event.doseOption,
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
    emit(state.copyWith(status: PrescriptionStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));

    // إضافة الروشتة إلى MockData للمحاكاة
    final newPrescId = 'presc-new-${DateTime.now().millisecondsSinceEpoch}';
    
    MockData.prescriptions.add({
      'id': newPrescId,
      'appointment_id': state.appointmentId,
      'doctor_id': 'u-doc-1',
      'patient_id': 'p-1',
      'diagnosis': state.selectedDiagnosis.join(' ، ') + 
                   (state.finalDiagnosis.isNotEmpty ? ' - ${state.finalDiagnosis}' : ''),
      'notes': state.notes,
      'created_at': DateTime.now().toIso8601String(),
    });

    // تحديث حالة الموعد إلى Done
    for (int i = 0; i < MockData.appointments.length; i++) {
      if (MockData.appointments[i]['id'] == state.appointmentId) {
        MockData.appointments[i]['status'] = 'done';
      }
    }

    emit(state.copyWith(status: PrescriptionStatus.success));
  }

  void _onCopyPrevious(
    CopyPreviousPrescriptionEvent event,
    Emitter<PrescriptionState> emit,
  ) {
    // محاكاة نسخ آخر روشتة متوفرة في النظام للمريض
    // سنستخدم بيانات افتراضية لآخر روشتة
    final list = [
      SelectedDrugModel(
        id: 'd-1',
        tradeName: 'بندول شراب للأطفال',
        genericName: 'باراسيتامول البشري للأطفال',
        category: 'خافض حرارة',
        form: 'شراب',
        doseOption: '١٠ مل',
        doseFrequency: 'عند اللزوم',
        doseDuration: '٣ أيام',
        doseTiming: 'بعد الأكل',
        isPrn: true,
      ),
      SelectedDrugModel(
        id: 'd-2',
        tradeName: 'زيترون شراب مضاد حيوي',
        genericName: 'أزيثروميسين شراب',
        category: 'مضاد حيوي',
        form: 'شراب',
        doseOption: '٥ مل',
        doseFrequency: 'مرة واحدة يومياً',
        doseDuration: '٣ أيام',
        doseTiming: 'قبل الأكل',
        isPrn: false,
      )
    ];

    emit(state.copyWith(
      selectedDiagnosis: ['نزلة معوية حادة (A09)'],
      selectedDrugs: list,
    ));
  }
}
