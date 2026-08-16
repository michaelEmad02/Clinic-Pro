// ────────────────────────────────────────────────────────
// Cubit شاشة المرضى — يعتمد على UseCases فقط (Clean Architecture)
// لا يتعامل مع Repository مباشرة — يمرر عبر حالات الاستخدام
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/add_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';
import '../../domain/usecases/load_patients_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import 'patients_state.dart';

@injectable
class PatientsCubit extends Cubit<PatientsState> {
  final LoadPatientsUseCase _loadPatientsUseCase;
  final AddPatientUseCase _addPatientUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;
  final DeletePatientUseCase _deletePatientUseCase;

  PatientsCubit(
    this._loadPatientsUseCase,
    this._addPatientUseCase,
    this._updatePatientUseCase,
    this._deletePatientUseCase,
  ) : super(PatientsInitial());

  /// تحميل قائمة المرضى
  Future<void> loadPatients({required String clinicId}) async {
    emit(PatientsLoading());

    final patientsResult = await _loadPatientsUseCase(clinicId: clinicId);

    patientsResult.fold(
      (failure) => emit(PatientsError(failure.message)),
      (patients) => emit(PatientsLoaded(allPatients: patients)),
    );
  }

  /// البحث في قائمة المرضى بالاسم أو الهاتف
  void search(String query) {
    if (state is PatientsLoaded) {
      emit((state as PatientsLoaded).copyWith(searchQuery: query));
    }
  }

  /// تغيير الفلتر النشط
  void changeFilter(PatientsFilter filter) {
    if (state is PatientsLoaded) {
      emit((state as PatientsLoaded).copyWith(activeFilter: filter));
    }
  }

  /// إضافة مريض جديد
  Future<void> addPatient(PatientEntity patient, {String? ownerId}) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    final result = await _addPatientUseCase(patient, ownerId: ownerId);
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (newPatient) => emit(
        loaded.copyWith(allPatients: [...loaded.allPatients, newPatient]),
      ),
    );
  }

  /// تحديث بيانات مريض
  Future<void> updatePatient(PatientEntity updated) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    final result = await _updatePatientUseCase(updated);
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (updatedPatient) {
        final list = loaded.allPatients.map((p) {
          return p.id == updatedPatient.id ? updatedPatient : p;
        }).toList();
        emit(loaded.copyWith(allPatients: list));
      },
    );
  }

  /// حذف مريض
  Future<void> deletePatient(String id) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    final result = await _deletePatientUseCase(id);
    result.fold(
      (failure) => emit(PatientsError(failure.message)),
      (_) {
        final list = loaded.allPatients.where((p) => p.id != id).toList();
        emit(loaded.copyWith(allPatients: list));
      },
    );
  }
}
