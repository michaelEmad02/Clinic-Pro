// ────────────────────────────────────────────────────────
// نماذج قوالب الروشتة (PrescriptionTemplateModel & Item)
// ────────────────────────────────────────────────────────

import '../../domain/entities/prescription_template_entity.dart';
import 'drug_model.dart';

class PrescriptionTemplateItemModel extends PrescriptionTemplateItemEntity {
  const PrescriptionTemplateItemModel({
    required super.id,
    required super.templateId,
    required super.drugId,
    super.frequency,
    super.duration,
    super.isPrn = false,
    super.timing,
    super.drug,
  });

  factory PrescriptionTemplateItemModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionTemplateItemModel(
      id: json['id'] as String,
      templateId: json['template_id'] as String? ?? '',
      drugId: json['drug_id'] as String,
      frequency: json['frequency'] as int?,
      duration: json['duration'] as int?,
      isPrn: json['is_prn'] as bool? ?? false,
      timing: json['timing'] as String?,
      drug: json['drug'] != null
          ? DrugModel.fromJson(json['drug'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'drug_id': drugId,
      'frequency': frequency,
      'duration': duration,
      'is_prn': isPrn,
      'timing': timing,
    };
  }
}

class PrescriptionTemplateModel extends PrescriptionTemplateEntity {
  const PrescriptionTemplateModel({
    required super.id,
    required super.doctorId,
    required super.name,
    super.userCount = 0,
    super.items = const [],
  });

  factory PrescriptionTemplateModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final itemsList = rawItems != null
        ? rawItems
            .map((e) =>
                PrescriptionTemplateItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PrescriptionTemplateItemModel>[];

    return PrescriptionTemplateModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userCount: json['user_count'] as int? ?? 0,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'name': name,
      'user_count': userCount,
    };
  }
}
