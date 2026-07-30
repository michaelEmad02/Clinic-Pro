// ────────────────────────────────────────────────────────
// مصدر البيانات السحابي للروشتات (Prescription Remote Data Source)
// يتصل بـ ICloudService مباشرة لتحميل وحفظ البيانات باستخدام النماذج (Models)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../patients/data/models/patient_model.dart';
import '../../../staff_and_invitations/data/models/staff_model.dart';
import '../models/drug_model.dart';
import '../models/prescription_model.dart';
import '../models/prescription_template_model.dart';

abstract class IPrescriptionRemoteDataSource {
  Future<AppointmentModel> getAppointment(String appointmentId);
  Future<PatientModel> getPatient(String patientId);
  Future<StaffModel> getDoctor(String doctorId);
  Future<PrescriptionModel?> getLastPrescriptionForPatient(String patientId);
  Future<List<PrescriptionItemModel>> getPrescriptionItems(String prescriptionId);
  Future<List<DrugModel>> getDrugList();
  Future<PrescriptionModel> insertPrescription(PrescriptionModel prescription);
  Future<void> insertPrescriptionItem(PrescriptionItemModel item);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<List<PrescriptionTemplateModel>> getTemplates(String doctorId);
  Future<List<PrescriptionTemplateItemModel>> getTemplateItems(String templateId);
  Future<PrescriptionTemplateModel> insertTemplate(PrescriptionTemplateModel template);
  Future<void> insertTemplateItem(PrescriptionTemplateItemModel item);
  Future<void> deleteTemplateItems(String templateId);
  Future<void> deleteTemplate(String templateId);
  Future<void> updateTemplate(PrescriptionTemplateModel template);
  Future<DrugModel> insertDrug(DrugModel drug);
  Future<void> updateDrug(DrugModel drug);
  Future<void> deleteDrug(String id);
}

@LazySingleton(as: IPrescriptionRemoteDataSource)
class PrescriptionRemoteDataSourceImpl implements IPrescriptionRemoteDataSource {
  final ICloudService _cloud;

  PrescriptionRemoteDataSourceImpl(this._cloud);

  @override
  Future<AppointmentModel> getAppointment(String appointmentId) async {
    final results = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: {'id': appointmentId},
    );
    if (results.isEmpty) {
      throw Exception('Appointment not found');
    }
    return AppointmentModel.fromJson(results.first);
  }

  @override
  Future<PatientModel> getPatient(String patientId) async {
    final results = await _cloud.select(
      table: SupabaseTables.patients,
      eq: {'id': patientId},
    );
    if (results.isEmpty) {
      throw Exception('Patient not found');
    }
    return PatientModel.fromJson(results.first);
  }

  @override
  Future<StaffModel> getDoctor(String doctorId) async {
    // جدول المستخدمين أو الموظفين
    final results = await _cloud.select(
      table: SupabaseTables.users,
      eq: {'id': doctorId},
    );
    if (results.isEmpty) {
      throw Exception('Doctor user not found');
    }
    return StaffModel.fromJson(results.first);
  }

  @override
  Future<PrescriptionModel?> getLastPrescriptionForPatient(String patientId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptions,
      eq: {'patient_id': patientId},
      order: 'created_at',
      ascending: false,
    );
    if (results.isEmpty) return null;
    return PrescriptionModel.fromJson(results.first);
  }

  @override
  Future<List<PrescriptionItemModel>> getPrescriptionItems(String prescriptionId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptionItems,
      eq: {'prescription_id': prescriptionId},
    );
    return results.map((e) => PrescriptionItemModel.fromJson(e)).toList();
  }

  @override
  Future<List<DrugModel>> getDrugList() async {
    final results = await _cloud.select(table: SupabaseTables.drugs);
    return results.map((e) => DrugModel.fromJson(e)).toList();
  }

  @override
  Future<PrescriptionModel> insertPrescription(PrescriptionModel prescription) async {
    final data = prescription.toJson();
    final result = await _cloud.insert(
      table: SupabaseTables.prescriptions,
      data: data,
    );
    return PrescriptionModel.fromJson(result);
  }

  @override
  Future<void> insertPrescriptionItem(PrescriptionItemModel item) async {
    await _cloud.insert(
      table: SupabaseTables.prescriptionItems,
      data: item.toJson(),
    );
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _cloud.update(
      table: SupabaseTables.appointments,
      data: {'status': status},
      matchColumn: 'id',
      matchValue: appointmentId,
    );
  }

  @override
  Future<List<PrescriptionTemplateModel>> getTemplates(String doctorId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptionTemplates,
      eq: {'doctor_id': doctorId},
    );
    return results.map((e) => PrescriptionTemplateModel.fromJson(e)).toList();
  }

  @override
  Future<List<PrescriptionTemplateItemModel>> getTemplateItems(String templateId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptionTemplateItems,
      eq: {'template_id': templateId},
    );
    return results.map((e) => PrescriptionTemplateItemModel.fromJson(e)).toList();
  }

  @override
  Future<PrescriptionTemplateModel> insertTemplate(PrescriptionTemplateModel template) async {
    final result = await _cloud.insert(
      table: SupabaseTables.prescriptionTemplates,
      data: template.toJson(),
    );
    return PrescriptionTemplateModel.fromJson(result);
  }

  @override
  Future<void> insertTemplateItem(PrescriptionTemplateItemModel item) async {
    await _cloud.insert(
      table: SupabaseTables.prescriptionTemplateItems,
      data: item.toJson(),
    );
  }

  @override
  Future<void> deleteTemplateItems(String templateId) async {
    await _cloud.delete(
      table: SupabaseTables.prescriptionTemplateItems,
      matchColumn: 'template_id',
      matchValue: templateId,
    );
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    await _cloud.delete(
      table: SupabaseTables.prescriptionTemplates,
      matchColumn: 'id',
      matchValue: templateId,
    );
  }

  @override
  Future<void> updateTemplate(PrescriptionTemplateModel template) async {
    await _cloud.update(
      table: SupabaseTables.prescriptionTemplates,
      data: template.toJson(),
      matchColumn: 'id',
      matchValue: template.id,
    );
  }

  @override
  Future<DrugModel> insertDrug(DrugModel drug) async {
    final result = await _cloud.insert(
      table: SupabaseTables.drugs,
      data: drug.toJson(),
    );
    return DrugModel.fromJson(result);
  }

  @override
  Future<void> updateDrug(DrugModel drug) async {
    await _cloud.update(
      table: SupabaseTables.drugs,
      data: drug.toJson(),
      matchColumn: 'id',
      matchValue: drug.id,
    );
  }

  @override
  Future<void> deleteDrug(String id) async {
    await _cloud.delete(
      table: SupabaseTables.drugs,
      matchColumn: 'id',
      matchValue: id,
    );
  }
}
