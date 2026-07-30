// ────────────────────────────────────────────────────────
// كيان الدواء (DrugEntity)
// يمثل الهيكل الأساسي للدواء المستقل عن طبقة البيانات
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class DrugEntity extends Equatable {
  final String id;
  final String? tradeName;
  final String? genericName;
  final String? category;

  const DrugEntity({
    required this.id,
    this.tradeName,
    this.genericName,
    this.category,
  });

  @override
  List<Object?> get props => [id, tradeName, genericName, category];
}
