// ────────────────────────────────────────────────────────
// Cubit شاشة المرضى — تحميل وفلترة وإضافة/تعديل (Repository)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'patients_repository.dart';
import 'patients_state.dart';

@injectable
class PatientsCubit extends Cubit<PatientsState> {
  final PatientsRepository _repository;

  PatientsCubit(this._repository) : super(PatientsInitial());

  Future<void> loadPatients() async {
    emit(PatientsLoading());

    try {
      final items = await _repository.loadPatients();
      final doctors = await _repository.getDoctors();
      emit(PatientsLoaded(allPatients: items, doctors: doctors));
    } catch (_) {
      emit(PatientsError(AppStrings.loadPatientsFailed));
    }
  }

  void search(String query) {
    if (state is PatientsLoaded) {
      emit((state as PatientsLoaded).copyWith(searchQuery: query));
    }
  }

  void changeFilter(PatientsFilter filter) {
    if (state is PatientsLoaded) {
      emit((state as PatientsLoaded).copyWith(activeFilter: filter));
    }
  }

  Future<void> addPatient({
    required String name,
    required String phone,
    required String gender,
    String? birthDate,
    String? bloodType,
    String? allergies,
    String? chronicConditions,
    String? address,
    String? doctorId,
  }) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    try {
      final newPatient = await _repository.addPatient(
        name: name,
        phone: phone,
        gender: gender,
        birthDate: birthDate,
        bloodType: bloodType,
        allergies: allergies,
        chronicConditions: chronicConditions,
        address: address,
        doctorId: doctorId,
      );
      emit(loaded.copyWith(allPatients: [...loaded.allPatients, newPatient]));
    } catch (_) {
      emit(PatientsError(AppStrings.loadPatientsFailed));
    }
  }

  Future<void> updatePatient(PatientItem updated) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    try {
      final updatedPatient = await _repository.updatePatient(updated);
      final list = loaded.allPatients.map((p) {
        return p.id == updatedPatient.id ? updatedPatient : p;
      }).toList();
      emit(loaded.copyWith(allPatients: list));
    } catch (_) {
      emit(PatientsError(AppStrings.loadPatientsFailed));
    }
  }

  Future<void> deletePatient(String id) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;

    try {
      await _repository.deletePatient(id);
      final list = loaded.allPatients.where((p) => p.id != id).toList();
      emit(loaded.copyWith(allPatients: list));
    } catch (_) {
      emit(PatientsError(AppStrings.loadPatientsFailed));
    }
  }
}
