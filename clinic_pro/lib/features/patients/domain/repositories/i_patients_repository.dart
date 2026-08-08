// ────────────────────────────────────────────────────────
// واجهة مستودع المرضى (IPatientsRepository)
// تُعرّف العمليات الأساسية لإدارة بيانات المرضى
// كل method يرجع Either<Failure, T> لمعالجة الأخطاء
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../prescription/domain/entities/prescription_entity.dart';
import '../entities/patient_entity.dart';

abstract class IPatientsRepository {
  /// جلب قائمة مرضى عيادة محددة
  Future<Either<Failure, List<PatientEntity>>> getPatients({
    required String clinicId,
  });

  /// جلب بيانات مريض محدد باستخدام المعرف
  Future<Either<Failure, PatientEntity>> getPatientById(String id);

  /// إضافة مريض جديد
  Future<Either<Failure, PatientEntity>> addPatient(PatientEntity patient);

  /// تحديث بيانات مريض موجود
  Future<Either<Failure, PatientEntity>> updatePatient(PatientEntity patient);

  /// حذف مريض نهائياً
  Future<Either<Failure, Unit>> deletePatient(String id);

  /// جلب زيارات مريض محدد (مواعيد عبر كل عيادات المالك)
  Future<Either<Failure, List<AppointmentEntity>>> getVisitsForPatient(
    String patientId,
  );

  /// جلب روشتات مريض محدد
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptionsForPatient(
    String patientId,
  );
}

