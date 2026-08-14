import '../../domain/entities/reports_entities.dart';

class DrugCategoryStatModel extends DrugCategoryStatEntity {
  const DrugCategoryStatModel({
    required super.category,
    required super.count,
    required super.percentage,
  });

  factory DrugCategoryStatModel.fromMap(Map<String, dynamic> map) {
    return DrugCategoryStatModel(
      category: map['category'] as String,
      count: map['count'] as int,
      percentage: (map['percentage'] as num).toDouble(),
    );
  }
}

class TopDrugStatModel extends TopDrugStatEntity {
  const TopDrugStatModel({
    required super.name,
    required super.count,
    required super.percentage,
  });

  factory TopDrugStatModel.fromMap(Map<String, dynamic> map) {
    return TopDrugStatModel(
      name: map['name'] as String,
      count: map['count'] as int,
      percentage: (map['percentage'] as num).toDouble(),
    );
  }
}

class DrugStatsModel extends DrugStatsEntity {
  const DrugStatsModel({
    required super.byCategory,
    required super.topDrugs,
  });

  factory DrugStatsModel.empty() {
    return const DrugStatsModel(
      byCategory: [],
      topDrugs: [],
    );
  }

  factory DrugStatsModel.fromRawData({
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> topDrugs,
  }) {
    return DrugStatsModel(
      byCategory: categories.map((c) => DrugCategoryStatModel.fromMap(c)).toList(),
      topDrugs: topDrugs.map((d) => TopDrugStatModel.fromMap(d)).toList(),
    );
  }
}
