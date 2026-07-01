// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة عمليات المرضى البيانية (Data Layer)
// يستخدم ICloudService كطبقة تواصل مع قاعدة البيانات
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'patients_state.dart';

@injectable
class PatientsRepository {
  final ICloudService _cloud;

  PatientsRepository(this._cloud);

  Future<List<PatientItem>> loadPatients() async {
    final data = await _cloud.select(table: 'patients');
    return data.map((raw) => _mapPatientItem(raw)).toList();
  }

  Future<PatientItem> addPatient({
    required String name,
    required String phone,
    required String gender,
    String? birthDate,
    String? bloodType,
    String? allergies,
    String? chronicConditions,
    String? address,
  }) async {
    final data = await _cloud.insert(table: 'patients', data: {
      'name': name,
      'phone': phone,
      'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (chronicConditions != null) 'chronic_conditions': chronicConditions,
      if (address != null) 'address': address,
    });
    return _mapPatientItem(data);
  }

  Future<PatientItem> updatePatient(PatientItem updated) async {
    final data = await _cloud.update(
      table: 'patients',
      data: {
        'name': updated.name,
        'phone': updated.phone,
        'gender': updated.gender,
        if (updated.birthDate != null) 'birth_date': updated.birthDate,
        if (updated.bloodType != null) 'blood_type': updated.bloodType,
        'allergies': updated.allergies,
        'chronic_conditions': updated.chronicConditions,
        if (updated.address != null) 'address': updated.address,
      },
      matchColumn: 'id',
      matchValue: updated.id,
    );
    return _mapPatientItem(data.first);
  }

  Future<void> deletePatient(String id) async {
    await _cloud.delete(
      table: 'patients',
      matchColumn: 'id',
      matchValue: id,
    );
  }

  Future<List<PatientVisitItem>> getVisitsForPatient(String patientId) async {
    final data = await _cloud.select(
      table: 'patient_visits',
      eq: {'patient_id': patientId},
    );
    return data.map((v) => PatientVisitItem(
      id: v['id'] as String,
      title: v['title'] as String,
      displayDate: v['display_date'] as String,
      description: v['description'] as String,
      doctorName: v['doctor_name'] as String,
    )).toList();
  }

  Future<List<PatientPrescriptionRecordItem>> getPrescriptionsForPatient(
      String patientId) async {
    final data = await _cloud.select(
      table: 'patient_prescription_records',
      eq: {'patient_id': patientId},
    );
    return data.map((p) => PatientPrescriptionRecordItem(
      id: p['id'] as String,
      title: p['title'] as String,
      displayDate: p['display_date'] as String,
      doctorName: p['doctor_name'] as String,
    )).toList();
  }

  Future<PatientItem?> findPatientById(String id) async {
    final data = await _cloud.select(table: 'patients', eq: {'id': id});
    if (data.isEmpty) return null;
    return _mapPatientItem(data.first);
  }

  PatientItem _mapPatientItem(Map<String, dynamic> raw) {
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
  }
}
