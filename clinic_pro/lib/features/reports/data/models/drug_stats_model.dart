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
    super.totalPrescriptions = 0,
    super.avgDrugsPerPrescription = 0.0,
    super.prnPercentage = 0.0,
    super.topDiagnosisName = '',
    required super.byCategory,
    required super.topDrugs,
    super.topDiagnoses = const [],
    super.templateStats = const [],
    super.monthlyTrend = const [],
    super.commonDosages = const [],
    super.chronicDrugs = const [],
    super.drugDiagnosisLinks = const [],
    super.repeatedDrugs = const [],
    super.switchedDrugs = const [],
    super.patientReach = const [],
  });

  factory DrugStatsModel.empty() {
    return const DrugStatsModel(
      byCategory: [],
      topDrugs: [],
    );
  }

  factory DrugStatsModel.fromMap(Map<String, dynamic> map) {
    final catList = ((map['categories'] ?? map['by_category'] ?? []) as List)
        .map((c) => DrugCategoryStatModel.fromMap(c as Map<String, dynamic>))
        .toList();
    final topList = ((map['top_drugs'] ?? []) as List)
        .map((d) => TopDrugStatModel.fromMap(d as Map<String, dynamic>))
        .toList();
    final topDiagList = ((map['top_diagnoses'] ?? []) as List)
        .map((td) => NameCountStatEntity(
              name: td['name'] as String? ?? '',
              count: (td['count'] ?? 0) as int,
              percentage: ((td['percentage'] ?? 0.0) as num).toDouble(),
            ))
        .toList();
    final chronicList = ((map['chronic_drugs'] ?? []) as List)
        .map((cd) => TopDrugStatModel.fromMap(cd as Map<String, dynamic>))
        .toList();
    final templates = ((map['template_stats'] ?? []) as List)
        .map((t) => TemplateStatsEntity(
              id: (t['id'] ?? '').toString(),
              name: t['name'] as String? ?? '',
              userCount: (t['user_count'] ?? 0) as int,
              percentage: ((t['percentage'] ?? 0.0) as num).toDouble(),
            ))
        .toList();
    final monthlyTrend = ((map['monthly_trend'] ?? []) as List)
        .map((m) => MonthlyPrescriptionTrendEntity(
              month: m['month'] as String? ?? '',
              count: (m['count'] ?? 0) as int,
              avgDrugs: ((m['avg_drugs'] ?? 0.0) as num).toDouble(),
            ))
        .toList();
    final commonDosages = ((map['common_dosages'] ?? []) as List)
        .map((cdos) => DosingPatternStatEntity(
              pattern: cdos['pattern'] as String? ?? '',
              count: (cdos['count'] ?? 0) as int,
              percentage: ((cdos['percentage'] ?? 0.0) as num).toDouble(),
            ))
        .toList();
    final drugDiagLinks = ((map['drug_diagnosis_links'] ?? []) as List)
        .map((ddl) => DrugDiagnosisStatEntity(
              diagnosis: ddl['diagnosis'] as String? ?? '',
              drugName: ddl['drug_name'] as String? ?? '',
              count: (ddl['count'] ?? 0) as int,
            ))
        .toList();
    final repeated = ((map['repeated_drugs'] ?? []) as List)
        .map((rd) => RepeatDrugStatEntity(
              drugName: rd['drug_name'] as String? ?? '',
              repeatCount: (rd['repeat_count'] ?? 0) as int,
              patientCount: (rd['patient_count'] ?? 0) as int,
            ))
        .toList();
    final patientReach = ((map['patient_reach'] ?? []) as List)
        .map((pr) => PatientReachStatEntity(
              drugName: pr['drug_name'] as String? ?? '',
              uniquePatients: (pr['unique_patients'] ?? 0) as int,
              totalPrescribedCount: (pr['total_prescribed_count'] ?? 0) as int,
            ))
        .toList();

    return DrugStatsModel(
      totalPrescriptions: (map['total_prescriptions'] ?? 0) as int,
      avgDrugsPerPrescription: ((map['avg_drugs_per_prescription'] ?? 0.0) as num).toDouble(),
      prnPercentage: ((map['prn_percentage'] ?? 0.0) as num).toDouble(),
      topDiagnosisName: map['top_diagnosis_name'] as String? ?? '',
      byCategory: catList,
      topDrugs: topList,
      topDiagnoses: topDiagList,
      templateStats: templates,
      monthlyTrend: monthlyTrend,
      commonDosages: commonDosages,
      chronicDrugs: chronicList,
      drugDiagnosisLinks: drugDiagLinks,
      repeatedDrugs: repeated,
      patientReach: patientReach,
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
