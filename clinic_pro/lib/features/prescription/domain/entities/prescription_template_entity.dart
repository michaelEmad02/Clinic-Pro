// ────────────────────────────────────────────────────────
// كيان قوالب الروشتات (PrescriptionTemplateEntity)
// يمثل قالب الروشتة والأدوية المرتبطة به
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'drug_entity.dart';

class PrescriptionTemplateItemEntity extends Equatable {
  final String id;
  final String templateId;
  final String drugId;
  final int? frequency;
  final int? duration;
  final bool isPrn;
  final String? timing;
  final DrugEntity? drug;

  const PrescriptionTemplateItemEntity({
    required this.id,
    required this.templateId,
    required this.drugId,
    this.frequency,
    this.duration,
    this.isPrn = false,
    this.timing,
    this.drug,
  });

  @override
  List<Object?> get props => [
        id,
        templateId,
        drugId,
        frequency,
        duration,
        isPrn,
        timing,
        drug,
      ];
}

class PrescriptionTemplateEntity extends Equatable {
  final String id;
  final String doctorId;
  final String name;
  final int userCount;
  final List<PrescriptionTemplateItemEntity> items;

  const PrescriptionTemplateEntity({
    required this.id,
    required this.doctorId,
    required this.name,
    this.userCount = 0,
    this.items = const [],
  });

  @override
  List<Object?> get props => [id, doctorId, name, userCount, items];
}
