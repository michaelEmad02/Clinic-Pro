import 'dart:typed_data';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/domain/repositories/i_prescription_repository.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';

@injectable
class GeneratePrescriptionPdfUseCase {
  final IPrescriptionRepository _repository;

  GeneratePrescriptionPdfUseCase(this._repository);

  Future<Either<Failure, Uint8List>> call({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    bool isA5Format = false,
  }) {
    return _repository.generatePrescriptionPdf(
      prescription: prescription,
      clinic: clinic,
      doctor: doctor,
      patient: patient,
      printingSettings: printingSettings,
      includeHeader: includeHeader,
      isA5Format: isA5Format,
    );
  }
}
