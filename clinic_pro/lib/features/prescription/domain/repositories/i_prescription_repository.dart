// ────────────────────────────────────────────────────────
// واجهة مستودع الروشتات (IPrescriptionRepository)
// تحدد العمليات المنطقية لميزة الروشتات مستقلة عن طبقة البيانات
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/drug_entity.dart';
import '../entities/prescription_entity.dart';
import '../entities/prescription_load_data_entity.dart';
import '../entities/prescription_template_entity.dart';

abstract class IPrescriptionRepository {
  /// تحميل كافة البيانات المطلوبة لبدء الروشتة (زيارة ومريض وطبيب وآخر روشتة)
  Future<Either<Failure, PrescriptionLoadDataEntity>> getPrescriptionData(
    String appointmentId,
    String doctorId,
  );

  /// حفظ الروشتة الطبية وأدويتها في قاعدة البيانات
  Future<Either<Failure, void>> savePrescription(
    PrescriptionEntity prescription,
    String doctorId,
  );

  /// نسخ الأدوية والتشخيصات من آخر روشتة للمريض
  Future<Either<Failure, (List<PrescriptionItemEntity>, List<String>)>>
      copyPreviousPrescription(String patientId);

  /// جلب أدوية قالب معين لتطبيقها على الروشتة الحالية
  Future<Either<Failure, (List<PrescriptionItemEntity>, String)>>
      getTemplateData(String templateId, String doctorId);

  /// جلب كافة قوالب الروشتات
  Future<Either<Failure, List<PrescriptionTemplateEntity>>> getTemplates(
    String doctorId,
  );

  /// إضافة قالب روشتة جديد
  Future<Either<Failure, PrescriptionTemplateEntity>> addTemplate(
    PrescriptionTemplateEntity template,
    String doctorId,
  );

  /// تعديل قالب روشتة موجود
  Future<Either<Failure, void>> editTemplate(
    PrescriptionTemplateEntity template,
  );

  /// حذف قالب روشتة وأدويته
  Future<Either<Failure, void>> deleteTemplate(String id);

  /// جلب قائمة الأدوية
  Future<Either<Failure, List<DrugEntity>>> getDrugs();

  /// إضافة دواء جديد
  Future<Either<Failure, DrugEntity>> addDrug(DrugEntity drug);

  /// تعديل دواء موجود
  Future<Either<Failure, void>> updateDrug(DrugEntity drug);

  /// حذف دواء
  Future<Either<Failure, void>> deleteDrug(String id);
}
