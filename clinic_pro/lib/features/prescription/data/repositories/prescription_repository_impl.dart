// ────────────────────────────────────────────────────────
// تنفيذ مستودع الروشتات (PrescriptionRepositoryImpl)
// يقوم بالتواصل مع مصدر البيانات السحابي وتحويل النماذج إلى كيانات منطقية
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../patients/data/models/patient_model.dart';
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
    AppointmentEntity appt,
    String doctorId,
  ) async {
    try {
      final appointmentId = appt.id;
      final patientId = appt.patientId;

      String patientName = appt.patientName ?? '';
      String patientGender = 'ذكر';
      String patientBirthDate = '1990-01-01';
      String bloodType = 'O+';

      try {
        final PatientModel patient =
            await _remoteDataSource.getPatient(patientId);
        patientName = patient.name.isNotEmpty ? patient.name : patientName;
        patientGender = patient.gender;
        patientBirthDate = patient.dateOfBirth ?? '1990-01-01';
        bloodType = patient.bloodType ?? 'O+';
      } catch (_) {}

      String doctorName = appt.doctorName ?? AppStrings.generalPractitioner;
      if (doctorName.isEmpty || doctorName == AppStrings.generalPractitioner) {
        try {
          doctorName = await _remoteDataSource.getDoctorName(doctorId);
        } catch (_) {}
      }

      final typeName = (appt.typeName != null && appt.typeName!.isNotEmpty)
          ? appt.typeName!
          : AppStrings.normalCheckup;

      List<String> selectedDiag = [];
      List<PrescriptionItemEntity> selectedDrugs = [];
      String prescNotes = '';
      String finalDiag = appt.notes ?? '';
      String? prescriptionId;

      final existingPrescriptionModel =
          await _remoteDataSource.getPrescriptionByAppointment(appointmentId);

      if (existingPrescriptionModel != null) {
        prescriptionId = existingPrescriptionModel.id;

        final itemModels = await _remoteDataSource
            .getPrescriptionItems(existingPrescriptionModel.id);
        final drugs = await _remoteDataSource.getDrugList();
        final drugsMap = {for (var d in drugs) d.id: d};

        selectedDrugs = itemModels.map((im) {
          final dModel = drugsMap[im.drugId];
          return PrescriptionItemEntity(
            id: im.id,
            prescriptionId: existingPrescriptionModel.id,
            drugId: im.drugId,
            frequency: im.frequency,
            duration: im.duration,
            timing: im.timing,
            isPrn: im.isPrn,
            drug: dModel != null
                ? DrugEntity(
                    id: dModel.id,
                    tradeName: dModel.tradeName ?? '',
                    genericName: dModel.genericName,
                    category: dModel.category,
                  )
                : null,
          );
        }).toList();

        if (existingPrescriptionModel.diagnosis != null &&
            existingPrescriptionModel.diagnosis!.isNotEmpty) {
          selectedDiag = existingPrescriptionModel.diagnosis!.split(', ');
        }
        prescNotes = existingPrescriptionModel.notes ?? '';
      }

      return Right(PrescriptionLoadDataEntity(
        appointmentId: appointmentId,
        patientId: patientId,
        patientName: patientName,
        patientGender: patientGender,
        patientBirthDate: patientBirthDate,
        bloodType: bloodType,
        clinicId: appt.clinicId,
        visitType: typeName,
        doctorName: doctorName,
        visitDate: appt.date,
        selectedDiagnosis: selectedDiag,
        selectedDrugs: selectedDrugs,
        finalDiagnosis: finalDiag,
        notes: prescNotes,
        prescriptionId: prescriptionId,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptionsForPatient(
    String patientId,
  ) async {
    try {
      final models =
          await _remoteDataSource.getPrescriptionsForPatient(patientId);
      if (models.isEmpty) return const Right([]);

      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (var d in drugs) d.id: d};

      final List<PrescriptionEntity> result = [];

      for (final model in models) {
        final itemModels =
            await _remoteDataSource.getPrescriptionItems(model.id);
        final items = itemModels.map((im) {
          final dModel = drugsMap[im.drugId];
          return PrescriptionItemEntity(
            id: im.id,
            prescriptionId: model.id,
            drugId: im.drugId,
            frequency: im.frequency,
            duration: im.duration,
            timing: im.timing,
            isPrn: im.isPrn,
            drug: dModel != null
                ? DrugEntity(
                    id: dModel.id,
                    tradeName: dModel.tradeName ?? '',
                    genericName: dModel.genericName,
                    category: dModel.category,
                  )
                : null,
          );
        }).toList();

        result.add(PrescriptionEntity(
          id: model.id,
          createdAt: model.createdAt,
          clinicId: model.clinicId,
          doctorId: model.doctorId,
          patientId: model.patientId,
          appointmentId: model.appointmentId,
          diagnosis: model.diagnosis,
          notes: model.notes,
          items: items,
        ));
      }

      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePrescription(
    PrescriptionEntity prescription,
    String doctorId,
  ) async {
    try {
      final model = PrescriptionModel(
        id: prescription.id.isNotEmpty ? prescription.id : '',
        createdAt: prescription.createdAt,
        appointmentId: prescription.appointmentId ?? '',
        patientId: prescription.patientId ?? '',
        doctorId: doctorId,
        clinicId: prescription.clinicId ?? '',
        diagnosis: prescription.diagnosis,
        notes: prescription.notes,
      );

      final savedModel =
          await _remoteDataSource.insertPrescription(model);

      for (final item in prescription.items) {
        final itemModel = PrescriptionItemModel(
          id: item.id,
          prescriptionId: savedModel.id,
          drugId: item.drugId ?? '',
          frequency: item.frequency,
          duration: item.duration,
          timing: item.timing,
          isPrn: item.isPrn,
        );
        await _remoteDataSource.insertPrescriptionItem(itemModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<PrescriptionItemEntity>, List<String>)>>
      copyPreviousPrescription(String patientId) async {
    try {
      final lastModel =
          await _remoteDataSource.getLastPrescriptionForPatient(patientId);
      if (lastModel == null) return const Right(([], []));

      final itemModels =
          await _remoteDataSource.getPrescriptionItems(lastModel.id);
      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (var d in drugs) d.id: d};

      final items = itemModels.map((im) {
        final dModel = drugsMap[im.drugId];
        return PrescriptionItemEntity(
          id: im.id,
          prescriptionId: lastModel.id,
          drugId: im.drugId,
          frequency: im.frequency,
          duration: im.duration,
          timing: im.timing,
          isPrn: im.isPrn,
          drug: dModel != null
              ? DrugEntity(
                  id: dModel.id,
                  tradeName: dModel.tradeName ?? '',
                  genericName: dModel.genericName,
                  category: dModel.category,
                )
              : null,
        );
      }).toList();

      List<String> diags = [];
      if (lastModel.diagnosis != null && lastModel.diagnosis!.isNotEmpty) {
        diags = lastModel.diagnosis!.split(', ');
      }

      return Right((items, diags));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<PrescriptionItemEntity>, String)>>
      getTemplateData(String templateId, String doctorId) async {
    try {
      final itemModels =
          await _remoteDataSource.getTemplateItems(templateId);
      final drugs = await _remoteDataSource.getDrugList();
      final drugsMap = {for (var d in drugs) d.id: d};

      final items = itemModels.map((im) {
        final dModel = drugsMap[im.drugId];
        return PrescriptionItemEntity(
          id: im.id,
          prescriptionId: '',
          drugId: im.drugId,
          frequency: im.frequency,
          duration: im.duration,
          timing: im.timing,
          isPrn: im.isPrn,
          drug: dModel != null
              ? DrugEntity(
                  id: dModel.id,
                  tradeName: dModel.tradeName ?? '',
                  genericName: dModel.genericName,
                  category: dModel.category,
                )
              : null,
        );
      }).toList();

      return Right((items, ''));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionTemplateEntity>>> getTemplates(
    String doctorId,
  ) async {
    try {
      final models = await _remoteDataSource.getTemplates(doctorId);
      return Right(models
          .map((m) => PrescriptionTemplateEntity(
                id: m.id,
                name: m.name,
                doctorId: m.doctorId,
              ))
          .toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionTemplateEntity>> addTemplate(
    PrescriptionTemplateEntity template,
    String doctorId,
  ) async {
    try {
      final model = PrescriptionTemplateModel(
        id: template.id,
        name: template.name,
        doctorId: doctorId,
      );
      final saved = await _remoteDataSource.insertTemplate(model);
      return Right(PrescriptionTemplateEntity(
        id: saved.id,
        name: saved.name,
        doctorId: saved.doctorId,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editTemplate(
    PrescriptionTemplateEntity template,
  ) async {
    try {
      final model = PrescriptionTemplateModel(
        id: template.id,
        name: template.name,
        doctorId: template.doctorId ?? '',
      );
      await _remoteDataSource.updateTemplate(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) async {
    try {
      await _remoteDataSource.deleteTemplate(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DrugEntity>>> getDrugs() async {
    try {
      final models = await _remoteDataSource.getDrugList();
      return Right(models
          .map((m) => DrugEntity(
                id: m.id,
                tradeName: m.tradeName,
                genericName: m.genericName,
                category: m.category,
              ))
          .toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DrugEntity>> addDrug(DrugEntity drug) async {
    try {
      final model = DrugModel(
        id: drug.id,
        tradeName: drug.tradeName,
        genericName: drug.genericName,
        category: drug.category,
      );
      final saved = await _remoteDataSource.insertDrug(model);
      return Right(DrugEntity(
        id: saved.id,
        tradeName: saved.tradeName ?? '',
        genericName: saved.genericName,
        category: saved.category,
      ));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDrug(DrugEntity drug) async {
    try {
      final model = DrugModel(
        id: drug.id,
        tradeName: drug.tradeName,
        genericName: drug.genericName,
        category: drug.category,
      );
      await _remoteDataSource.updateDrug(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDrug(String id) async {
    try {
      await _remoteDataSource.deleteDrug(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}
