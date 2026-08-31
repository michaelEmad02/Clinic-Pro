// ────────────────────────────────────────────────────────
// نموذج الدواء (DrugModel)
// يرث DrugEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/drug_entity.dart';

class DrugModel extends DrugEntity {
  const DrugModel({
    required super.id,
    super.tradeName,
    super.genericName,
    super.category,
  });

  factory DrugModel.fromJson(Map<String, dynamic> json) {
    return DrugModel(
      id: json['id'] as String,
      tradeName: json['trade_name'] as String?,
      genericName: json['generic_name'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trade_name': tradeName,
      'generic_name': genericName,
      'category': category,
    };
  }
}
