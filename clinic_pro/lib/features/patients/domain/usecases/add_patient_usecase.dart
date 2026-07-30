// ────────────────────────────────────────────────────────
// حالة استخدام إضافة مريض جديد (AddPatientUseCase)
// يتحقق من صحة المدخلات الأساسية قبل الإضافة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class AddPatientUseCase {
  final IPatientsRepository _repository;

  AddPatientUseCase(this._repository);

  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) async {
    // التحقق من الاسم — مطلوب ولا يقل عن حرفين
    if (patient.name.trim().length < 2) {
      return const Left(
        AddPatientFailure('اسم المريض مطلوب ولا يقل عن حرفين'),
      );
    }

    // التحقق من الجنس — مطلوب
    if (patient.gender.isEmpty) {
      return const Left(
        AddPatientFailure('الجنس مطلوب لإضافة مريض'),
      );
    }

    // التحقق من تاريخ الميلاد — يجب أن يكون في الماضي إن وُجد
    if (patient.dateOfBirth != null && patient.dateOfBirth!.isNotEmpty) {
      final dob = DateTime.tryParse(patient.dateOfBirth!);
      if (dob != null && dob.isAfter(DateTime.now())) {
        return const Left(
          AddPatientFailure('تاريخ الميلاد يجب أن يكون في الماضي'),
        );
      }
    }

    return _repository.addPatient(patient);
  }
}

class AddPatientFailure extends Failure {
  const AddPatientFailure(super.message);
}
