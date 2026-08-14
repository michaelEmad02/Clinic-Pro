import '../../domain/entities/reports_entities.dart';

class TemplateStatsModel extends TemplateStatsEntity {
  const TemplateStatsModel({
    required super.id,
    required super.name,
    required super.userCount,
    required super.percentage,
  });

  factory TemplateStatsModel.fromMap(Map<String, dynamic> map, {double percentage = 0.0}) {
    return TemplateStatsModel(
      id: map['id'] as String,
      name: map['name'] as String,
      userCount: (map['user_count'] ?? 0) as int,
      percentage: percentage,
    );
  }

  /// Creates a list of TemplateStatsModel from raw template data,
  /// calculating percentages based on total usage count.
  static List<TemplateStatsModel> fromRawList(List<Map<String, dynamic>> rawTemplates) {
    final totalUsage = rawTemplates.fold<int>(
      0,
      (sum, t) => sum + ((t['user_count'] ?? 0) as int),
    );

    return rawTemplates.map((t) {
      final count = (t['user_count'] ?? 0) as int;
      final pct = totalUsage > 0 ? (count / totalUsage * 100) : 0.0;
      return TemplateStatsModel.fromMap(t, percentage: pct);
    }).toList();
  }
}
