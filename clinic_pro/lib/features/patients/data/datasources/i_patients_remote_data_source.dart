// ────────────────────────────────────────────────────────
// واجهة مصدر بيانات المرضى البعيد (IPatientsRemoteDataSource)
// تحدد العمليات الأساسية لجلب وإدارة بيانات المرضى من الخادم السحابي
// ────────────────────────────────────────────────────────

import '../../../appointments/data/models/appointment_model.dart';
import '../../../prescription/data/models/prescription_model.dart';
import '../models/patient_model.dart';

abstract class IPatientsRemoteDataSource {
  /// جلب قائمة مرضى عيادة محددة
  Future<List<PatientModel>> getPatients({required String clinicId});

  /// جلب مريض محدد بناءً على معرفه الفريد
  Future<PatientModel> getPatientById(String id);

  /// إدخال مريض جديد في قاعدة البيانات
  Future<PatientModel> insertPatient(PatientModel patient);

  /// تحديث بيانات مريض موجود
  Future<PatientModel> updatePatient(PatientModel patient);

  /// حذف مريض من قاعدة البيانات
  Future<void> deletePatient(String id);

  /// جلب زيارات (مواعيد) مريض محدد
  Future<List<AppointmentModel>> getVisitsForPatient(String patientId);

  /// جلب روشتات مريض محدد
  Future<List<PrescriptionModel>> getPrescriptionsForPatient(String patientId);
}
