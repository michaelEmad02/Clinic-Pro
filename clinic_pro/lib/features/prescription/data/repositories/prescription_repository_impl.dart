// ────────────────────────────────────────────────────────
// تنفيذ مستودع الروشتات (PrescriptionRepositoryImpl)
// يقوم بالتواصل مع مصدر البيانات السحابي وتحويل النماذج إلى كيانات منطقية
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../patients/data/models/patient_model.dart';
import '../../../staff_and_invitations/data/models/staff_model.dart';
import '../../domain/entities/drug_entity.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/prescription_load_data_entity.dart';
import '../../domain/entities/prescription_template_entity.dart';
import '../../domain/repositories/i_prescription_repository.dart';
import '../datasources/prescription_remote_data_source.dart';
import '../models/drug_model.dart';
import '../models/prescription_model.dart';
import '../models/prescription_template_model.dart';

@LazySingleton(as: IPrescriptionRepository)
class PrescriptionRepositoryImpl implements IPrescriptionRepository {
  final IPrescriptionRemoteDataSource _remoteDataSource;

  PrescriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PrescriptionLoadDataEntity>> getPrescriptionData(
    String appointmentId,
    String doctorId,
  ) async {
    try {
      final AppointmentModel appt = await _remoteDataSource.getAppointment(appointmentId);
      final patientId = appt.patientId;

      final PatientModel patient = await _remoteDataSource.getPatient(patientId);

      String doctorName = AppStrings.generalPractitioner;
      try {
        final StaffModel doctor = await _remoteDataSource.getDoctor(doctorId);
        doctorName = doctor.name;
      } catch (_) {}

      final typeName = appt.typeName ?? AppStrings.normalCheckup;

      List<String> selectedDiag = [];
      List<PrescriptionItemEntity> selectedDrugs = [];
      String prescNotes = '';
      String finalDiag = appt.notes ?? '';

      final lastPresc = await _remoteDataSource.getLastPrescriptionForPatient(patientId);

      if (lastPresc != null) {
        prescNotes = lastPresc.notes ?? '';
        finalDiag = lastPresc.diagnosis ?? '';

        if (finalDiag.isNotEmpty) {
          selectedDiag = finalDiag.split(' ، ');
        }

        final items = await _remoteDataSource.getPrescriptionItems(lastPresc.id);
        final drugs = await _remoteDataSource.getDrugList();
        final drugsMap = {for (final d in drugs) d.id: d};

        for (final item in items) {
          final drug = drugsMap[item.drugId];
          selectedDrugs.add(PrescriptionItemModel(
            id: item.id,
            prescriptionId: item.prescriptionId,
            drugId: item.drugId,
            frequency: item.frequency,
            duration: item.duration,
            isPrn: item.isPrn,
            timing: item.timing,
            drug: drug,
          ));
        }
      }

      return Right(PrescriptionLoadDataEntity(
        appointmentId: appointmentId,
        patientId: patientId,
        patientName: patient.name,
        patientGender: patient.gender,
        patientBirthDate: patient.dateOfBirth ?? '1990-01-01',
        bloodType: patient.bloodType ?? 'O+',
        clinicId: appt.clinicId,
        visitType: typeName,
        doctorName: doctorName,
        visitDate: appt.date,
        selectedDiagnosis: selectedDiag,
        selectedDrugs: selectedDrugs,
        finalDiagnosis: finalDiag,
        notes: prescNotes,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePrescription(
    PrescriptionEntity prescription,
    String doctorId,
  ) async {
    try {
      final prescriptionModel = PrescriptionModel(
        id: prescription.id,
        clinicId: prescription.clinicId,
        doctorId: doctorId,
        patientId: prescription.patientId,
        diagnosis: prescription.diagnosis,
        notes: prescription.notes,
        createdAt: prescription.createdAt,
      );

      final newPresc = await _remoteDataSource.insertPrescription(prescriptionModel);

      for (final item in prescription.items) {
        final itemModel = PrescriptionItemModel(
          id: item.id,
          prescriptionId: newPresc.id,
          drugId: item.drugId,
          frequency: item.frequency,
          duration: item.duration,
          isPrn: item.isPrn,
          timing: item.timing,
        );
        await _remoteDataSource.insertPrescriptionItem(itemModel);
      }

      // تحديث إحصائيات استخدام قوالب التشخيصات
      if (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty) {
        final diagList = prescription.diagnosis!.split(' - ').first.split(' ، ');
        final templates = await _remoteDataSource.getTemplates(doctorId);

        for (final diag in diagList) {
          final match = templates.firstWhere(
            (t) => t.name == diag,
            orElse: () => const PrescriptionTemplateModel(id: '', doctorId: '', name: '', userCount: 0, items: []),
          );
          if (match.id.isNotEmpty) {
            final updatedTemplate = PrescriptionTemplateModel(
              id: match.id,
              doctorId: match.doctorId,
              name: match.name,
              userCount: match.userCount + 1,
            );
            await _remoteDataSource.updateTemplate(updatedTemplate);
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<PrescriptionItemEntity>, List<String>)>>
      copyPreviousPrescription(String patientId) async {
    try {
      final lastPresc = await _remoteDataSource.getLastPrescriptionForPatient(patientId);

      if (lastPresc == null) {
        return const Right((<PrescriptionItemEntity>[], <String>[]));
      }

      final items = await _remoteDataSource.getPrescriptionItems(lastPresc.id);
      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (final d in drugs) d.id: d};

      final List<PrescriptionItemEntity> copiedDrugs = [];
      for (final item in items) {
        final drug = drugsMap[item.drugId];
        copiedDrugs.add(PrescriptionItemModel(
          id: '',
          prescriptionId: '',
          drugId: item.drugId,
          frequency: item.frequency,
          duration: item.duration,
          isPrn: item.isPrn,
          timing: item.timing,
          drug: drug,
        ));
      }

      List<String> diags = [];
      if (lastPresc.diagnosis != null && lastPresc.diagnosis!.isNotEmpty) {
        diags = lastPresc.diagnosis!.split(' ، ');
      }

      return Right((copiedDrugs, diags));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<PrescriptionItemEntity>, String)>>
      getTemplateData(String templateId, String doctorId) async {
    try {
      final templateItems = await _remoteDataSource.getTemplateItems(templateId);
      final templates = await _remoteDataSource.getTemplates(doctorId);
      final template = templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => const PrescriptionTemplateModel(id: '', doctorId: '', name: '', userCount: 0, items: []),
      );
      final templateName = template.name;

      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (final d in drugs) d.id: d};

      final List<PrescriptionItemEntity> result = [];
      for (final item in templateItems) {
        final drug = drugsMap[item.drugId];
        result.add(PrescriptionItemModel(
          id: '',
          prescriptionId: '',
          drugId: item.drugId,
          frequency: item.frequency,
          duration: item.duration,
          isPrn: item.isPrn,
          timing: item.timing,
          drug: drug,
        ));
      }

      return Right((result, templateName));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionTemplateEntity>>>
      getTemplates(String doctorId) async {
    try {
      final rawTemplates = await _remoteDataSource.getTemplates(doctorId);
      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (final d in drugs) d.id: d};

      final List<PrescriptionTemplateEntity> templates = [];
      for (final t in rawTemplates) {
        final itemsRaw = await _remoteDataSource.getTemplateItems(t.id);

        final List<PrescriptionTemplateItemEntity> items = [];
        for (final item in itemsRaw) {
          final drug = drugsMap[item.drugId];
          items.add(PrescriptionTemplateItemModel(
            id: item.id,
            templateId: t.id,
            drugId: item.drugId,
            frequency: item.frequency,
            duration: item.duration,
            isPrn: item.isPrn,
            timing: item.timing,
            drug: drug,
          ));
        }

        templates.add(PrescriptionTemplateModel(
          id: t.id,
          doctorId: t.doctorId,
          name: t.name,
          userCount: t.userCount,
          items: items,
        ));
      }

      return Right(templates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionTemplateEntity>> addTemplate(
    PrescriptionTemplateEntity template,
    String doctorId,
  ) async {
    try {
      final templateModel = PrescriptionTemplateModel(
        id: template.id,
        doctorId: doctorId,
        name: template.name,
        userCount: template.userCount,
      );

      final newTemplate = await _remoteDataSource.insertTemplate(templateModel);

      for (final item in template.items) {
        final itemModel = PrescriptionTemplateItemModel(
          id: item.id,
          templateId: newTemplate.id,
          drugId: item.drugId,
          frequency: item.frequency,
          duration: item.duration,
          isPrn: item.isPrn,
          timing: item.timing,
        );
        await _remoteDataSource.insertTemplateItem(itemModel);
      }

      return Right(newTemplate);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editTemplate(
    PrescriptionTemplateEntity template,
  ) async {
    try {
      final templateModel = PrescriptionTemplateModel(
        id: template.id,
        doctorId: template.doctorId,
        name: template.name,
        userCount: template.userCount,
      );
      await _remoteDataSource.updateTemplate(templateModel);

      await _remoteDataSource.deleteTemplateItems(template.id);

      for (final item in template.items) {
        final itemModel = PrescriptionTemplateItemModel(
          id: item.id,
          templateId: template.id,
          drugId: item.drugId,
          frequency: item.frequency,
          duration: item.duration,
          isPrn: item.isPrn,
          timing: item.timing,
        );
        await _remoteDataSource.insertTemplateItem(itemModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) async {
    try {
      await _remoteDataSource.deleteTemplateItems(id);
      await _remoteDataSource.deleteTemplate(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DrugEntity>>> getDrugs() async {
    try {
      final list = await _remoteDataSource.getDrugList();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DrugEntity>> addDrug(DrugEntity drug) async {
    try {
      final drugModel = DrugModel(
        id: drug.id,
        tradeName: drug.tradeName,
        genericName: drug.genericName,
        category: drug.category,
      );
      final inserted = await _remoteDataSource.insertDrug(drugModel);
      return Right(inserted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDrug(DrugEntity drug) async {
    try {
      final drugModel = DrugModel(
        id: drug.id,
        tradeName: drug.tradeName,
        genericName: drug.genericName,
        category: drug.category,
      );
      await _remoteDataSource.updateDrug(drugModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDrug(String id) async {
    try {
      await _remoteDataSource.deleteDrug(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
