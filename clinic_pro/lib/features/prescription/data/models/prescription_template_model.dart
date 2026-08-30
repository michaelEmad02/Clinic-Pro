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
    int? parseNum(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return PrescriptionTemplateItemModel(
      id: json['id']?.toString() ?? '',
      templateId: json['template_id']?.toString() ?? '',
      drugId: json['drug_id']?.toString() ?? '',
      frequency: parseNum(json['frequency']),
      duration: parseNum(json['duration']),
      isPrn: json['is_prn'] as bool? ?? false,
      timing: json['timing'] as String?,
      drug: json['drugs'] != null
          ? DrugModel.fromJson(json['drugs'] as Map<String, dynamic>)
          : (json['drug'] != null
              ? DrugModel.fromJson(json['drug'] as Map<String, dynamic>)
              : null),
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
    final rawItems = json['prescription_template_items'] as List? ??
        json['items'] as List?;
    final itemsList = rawItems != null
        ? rawItems
            .map((e) =>
                PrescriptionTemplateItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <PrescriptionTemplateItemModel>[];

    return PrescriptionTemplateModel(
      id: json['id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      userCount: (json['user_count'] as num?)?.toInt() ?? 0,
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
