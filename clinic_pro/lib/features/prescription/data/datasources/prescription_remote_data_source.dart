// ────────────────────────────────────────────────────────
// مصدر البيانات السحابي للروشتات (Prescription Remote Data Source)
// يتصل بـ ICloudService مباشرة لتحميل وحفظ البيانات باستخدام النماذج (Models)
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/core/services/i_prescription_pdf_service.dart';
import 'package:clinic_pro/features/appointments/data/models/appointment_model.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/data/models/patient_model.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/data/models/drug_model.dart';
import 'package:clinic_pro/features/prescription/data/models/prescription_model.dart';
import 'package:clinic_pro/features/prescription/data/models/prescription_template_model.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:injectable/injectable.dart';

abstract class IPrescriptionRemoteDataSource {
  Future<AppointmentModel> getAppointment(String appointmentId);
  Future<PatientModel> getPatient(String patientId);
  Future<String> getDoctorName(String doctorId);
  Future<PrescriptionModel?> getPrescriptionByAppointment(String appointmentId);
  Future<void> updatePrescription(PrescriptionModel prescription);
  Future<void> deletePrescriptionItems(String prescriptionId);
  Future<PrescriptionModel?> getLastPrescriptionForPatient(String patientId);
  Future<List<PrescriptionModel>> getPrescriptionsForPatient(String patientId);
  Future<List<PrescriptionItemModel>> getPrescriptionItems(
      String prescriptionId);
  Future<List<DrugModel>> getDrugList();
  Future<PrescriptionModel> insertPrescription(PrescriptionModel prescription);
  Future<void> insertPrescriptionItem(PrescriptionItemModel item);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<List<PrescriptionTemplateModel>> getTemplates(String doctorId);
  Future<List<PrescriptionTemplateItemModel>> getTemplateItems(
      String templateId);
  Future<PrescriptionTemplateModel> insertTemplate(
      PrescriptionTemplateModel template);
  Future<void> insertTemplateItem(PrescriptionTemplateItemModel item);
  Future<void> deleteTemplateItems(String templateId);
  Future<void> deleteTemplate(String templateId);
  Future<void> updateTemplate(PrescriptionTemplateModel template);
  Future<DrugModel> insertDrug(DrugModel drug);
  Future<void> updateDrug(DrugModel drug);
  Future<void> deleteDrug(String id);

  /// توليد PDF الروشتة المكتمل بالبيانات الممررة
  Future<Uint8List> generatePrescriptionPdf({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    String pageFormat = 'A4',
    double? customWidth,
    double? customHeight,
  });
}

@LazySingleton(as: IPrescriptionRemoteDataSource)
class PrescriptionRemoteDataSourceImpl
    implements IPrescriptionRemoteDataSource {
  final ICloudService _cloud;
  final IPrescriptionPdfService _pdfService;

  PrescriptionRemoteDataSourceImpl(
    this._cloud,
    this._pdfService,
  );

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
  Future<String> getDoctorName(String doctorId) async {
    // جدول المستخدمين أو الموظفين
    final results = await _cloud.select(
      table: SupabaseTables.users,
      eq: {'id': doctorId},
    );
    if (results.isEmpty) {
      throw Exception('Doctor user not found');
    }
    return results.first["name"];
  }

  @override
  Future<PrescriptionModel?> getPrescriptionByAppointment(
      String appointmentId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptions,
      eq: {'appointment_id': appointmentId},
    );
    if (results.isEmpty) return null;
    return PrescriptionModel.fromJson(results.first);
  }

  @override
  Future<void> updatePrescription(PrescriptionModel prescription) async {
    await _cloud.update(
      table: SupabaseTables.prescriptions,
      data: prescription.toJson(),
      matchColumn: 'id',
      matchValue: prescription.id,
    );
  }

  @override
  Future<void> deletePrescriptionItems(String prescriptionId) async {
    await _cloud.delete(
      table: SupabaseTables.prescriptionItems,
      matchColumn: 'prescription_id',
      matchValue: prescriptionId,
    );
  }

  @override
  Future<PrescriptionModel?> getLastPrescriptionForPatient(
      String patientId) async {
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
  Future<List<PrescriptionModel>> getPrescriptionsForPatient(
      String patientId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptions,
      eq: {'patient_id': patientId},
      order: 'created_at',
      ascending: false,
    );
    return results.map((e) => PrescriptionModel.fromJson(e)).toList();
  }

  @override
  Future<List<PrescriptionItemModel>> getPrescriptionItems(
      String prescriptionId) async {
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
  Future<PrescriptionModel> insertPrescription(
      PrescriptionModel prescription) async {
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
  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
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
  Future<List<PrescriptionTemplateItemModel>> getTemplateItems(
      String templateId) async {
    final results = await _cloud.select(
      table: SupabaseTables.prescriptionTemplateItems,
      eq: {'template_id': templateId},
    );
    return results
        .map((e) => PrescriptionTemplateItemModel.fromJson(e))
        .toList();
  }

  @override
  Future<PrescriptionTemplateModel> insertTemplate(
      PrescriptionTemplateModel template) async {
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

  @override
  Future<Uint8List> generatePrescriptionPdf({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    String pageFormat = 'A4',
    double? customWidth,
    double? customHeight,
  }) async {
    // 1. جلب بيانات المريض إذا لم تكن ممررة
    PatientEntity? currentPatient = patient;
    if (currentPatient == null && prescription.patientId != null && prescription.patientId!.isNotEmpty) {
      try {
        currentPatient = await getPatient(prescription.patientId!);
      } catch (_) {}
    }

    // 2. تمرير الكائنات الممررة الجاهزة مباشرة لـ PDF Service
    return _pdfService.generatePrescriptionPdf(
      prescription: prescription,
      clinic: clinic,
      doctor: doctor,
      patient: currentPatient,
      printingSettings: printingSettings,
      includeHeader: includeHeader,
      pageFormat: pageFormat,
      customWidth: customWidth,
      customHeight: customHeight,
    );
  }
}
