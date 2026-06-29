// ────────────────────────────────────────────────────────
// Cubit شاشة المرضى — تحميل وفلترة وإضافة/تعديل (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());

  Future<void> loadPatients() async {
    emit(PatientsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapMockData();
      emit(PatientsLoaded(allPatients: items));
    } catch (_) {
      emit(const PatientsError('تعذّر تحميل قائمة المرضى'));
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
  }) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;
    await Future.delayed(const Duration(milliseconds: 400));

    final newPatient = PatientItem(
      id: 'p-new-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
      bloodType: bloodType,
      allergies: allergies ?? 'لا يوجد',
      chronicConditions: chronicConditions ?? 'لا يوجد',
      isChronic: (chronicConditions ?? '').isNotEmpty &&
          chronicConditions != 'لا يوجد',
      lastVisitLabel: 'لا توجد زيارات',
      address: address,
      statusTag: 'follow_up',
    );

    emit(loaded.copyWith(allPatients: [...loaded.allPatients, newPatient]));
  }

  Future<void> updatePatient(PatientItem updated) async {
    if (state is! PatientsLoaded) return;
    final loaded = state as PatientsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allPatients.map((p) {
      return p.id == updated.id ? updated : p;
    }).toList();

    emit(loaded.copyWith(allPatients: list));
  }

  /// تحويل MockData إلى PatientItem
  List<PatientItem> _mapMockData() {
    return MockData.patients.map((raw) {
      return PatientItem(
        id: raw['id'] as String,
        name: raw['name'] as String,
        phone: raw['phone'] as String,
        gender: raw['gender'] as String,
        birthDate: raw['birth_date'] as String?,
        bloodType: raw['blood_type'] as String?,
        email: raw['email'] as String?,
        address: raw['address'] as String?,
        emergencyContact: raw['emergency_contact'] as String?,
        allergies: raw['allergies'] as String? ?? 'لا يوجد',
        chronicConditions: raw['chronic_conditions'] as String? ?? 'لا يوجد',
        isChronic: raw['is_chronic'] as bool? ?? false,
        lastVisitLabel: raw['last_visit_label'] as String? ?? '—',
        lastVisitDate: raw['last_visit_date'] as String?,
        statusTag: raw['status_tag'] as String? ?? 'follow_up',
      );
    }).toList();
  }

  /// جلب زيارات مريض محدد
  static List<PatientVisitItem> getVisitsForPatient(String patientId) {
    return MockData.patientVisits
        .where((v) => v['patient_id'] == patientId)
        .map((v) => PatientVisitItem(
              id: v['id'] as String,
              title: v['title'] as String,
              displayDate: v['display_date'] as String,
              description: v['description'] as String,
              doctorName: v['doctor_name'] as String,
            ))
        .toList();
  }

  /// جلب روشتات مريض محدد
  static List<PatientPrescriptionRecordItem> getPrescriptionsForPatient(
      String patientId) {
    return MockData.patientPrescriptionRecords
        .where((p) => p['patient_id'] == patientId)
        .map((p) => PatientPrescriptionRecordItem(
              id: p['id'] as String,
              title: p['title'] as String,
              displayDate: p['display_date'] as String,
              doctorName: p['doctor_name'] as String,
            ))
        .toList();
  }

  /// البحث عن مريض بالـ ID
  static PatientItem? findPatientById(String id) {
    final raw = MockData.patients.where((p) => p['id'] == id).toList();
    if (raw.isEmpty) return null;
    final data = raw.first;
    return PatientItem(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String,
      gender: data['gender'] as String,
      birthDate: data['birth_date'] as String?,
      bloodType: data['blood_type'] as String?,
      email: data['email'] as String?,
      address: data['address'] as String?,
      emergencyContact: data['emergency_contact'] as String?,
      allergies: data['allergies'] as String? ?? 'لا يوجد',
      chronicConditions: data['chronic_conditions'] as String? ?? 'لا يوجد',
      isChronic: data['is_chronic'] as bool? ?? false,
      lastVisitLabel: data['last_visit_label'] as String? ?? '—',
      lastVisitDate: data['last_visit_date'] as String?,
      statusTag: data['status_tag'] as String? ?? 'follow_up',
    );
  }
}
