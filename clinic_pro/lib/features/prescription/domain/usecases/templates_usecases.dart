// ────────────────────────────────────────────────────────
// حالات استخدام قوالب الروشتات (Templates UseCases)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription_entity.dart';
import '../entities/prescription_template_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class GetTemplatesUseCase {
  final IPrescriptionRepository _repository;
  GetTemplatesUseCase(this._repository);

  Future<Either<Failure, List<PrescriptionTemplateEntity>>> call(String doctorId) {
    return _repository.getTemplates(doctorId);
  }
}

@injectable
class AddTemplateUseCase {
  final IPrescriptionRepository _repository;
  AddTemplateUseCase(this._repository);

  Future<Either<Failure, PrescriptionTemplateEntity>> call(
    PrescriptionTemplateEntity template,
    String doctorId,
  ) {
    if (template.name.trim().isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'اسم القالب مطلوب')));
    }
    return _repository.addTemplate(template, doctorId);
  }
}

@injectable
class EditTemplateUseCase {
  final IPrescriptionRepository _repository;
  EditTemplateUseCase(this._repository);

  Future<Either<Failure, void>> call(PrescriptionTemplateEntity template) {
    if (template.name.trim().isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'اسم القالب مطلوب')));
    }
    return _repository.editTemplate(template);
  }
}

@injectable
class DeleteTemplateUseCase {
  final IPrescriptionRepository _repository;
  DeleteTemplateUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteTemplate(id);
  }
}

@injectable
class GetTemplateDataUseCase {
  final IPrescriptionRepository _repository;
  GetTemplateDataUseCase(this._repository);

  Future<Either<Failure, (List<PrescriptionItemEntity>, String)>> call(
    String templateId,
    String doctorId,
  ) {
    return _repository.getTemplateData(templateId, doctorId);
  }
}
