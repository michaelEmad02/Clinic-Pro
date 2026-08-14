import '../../domain/entities/reports_entities.dart';

class InactivePatientModel extends InactivePatientEntity {
  const InactivePatientModel({
    required super.name,
    required super.lastVisit,
    required super.daysSinceLastVisit,
  });

  factory InactivePatientModel.fromMap(Map<String, dynamic> map) {
    return InactivePatientModel(
      name: map['name'] as String,
      lastVisit: map['last_visit'] as String,
      daysSinceLastVisit: map['days'] as int,
    );
  }
}

class PatientStatsModel extends PatientStatsEntity {
  const PatientStatsModel({
    required super.totalPatients,
    required super.newPatients,
    required super.returningPatients,
    required super.returnRate,
    super.avgVisitsPerPatient = 0.0,
    super.avgRevenuePerPatient = 0.0,
    super.newPatientsPercentage = 0.0,
    super.returningPatientsPercentage = 0.0,
    required super.byGender,
    required super.byAgeGroup,
    required super.inactivePatients,
  });

  factory PatientStatsModel.empty() {
    return const PatientStatsModel(
      totalPatients: 0,
      newPatients: 0,
      returningPatients: 0,
      returnRate: 0.0,
      avgVisitsPerPatient: 0.0,
      avgRevenuePerPatient: 0.0,
      newPatientsPercentage: 0.0,
      returningPatientsPercentage: 0.0,
      byGender: {'male': 0, 'female': 0},
      byAgeGroup: {
        '0-18': 0,
        '19-35': 0,
        '36-50': 0,
        '51-65': 0,
        '65+': 0,
      },
      inactivePatients: [],
    );
  }

  factory PatientStatsModel.fromMap(Map<String, dynamic> map) {
    return PatientStatsModel(
      totalPatients: (map['total'] ?? 0) as int,
      newPatients: (map['new'] ?? 0) as int,
      returningPatients: (map['returning'] ?? 0) as int,
      returnRate: ((map['return_rate'] ?? 0.0) as num).toDouble(),
      avgVisitsPerPatient: ((map['avg_visits_per_patient'] ?? 0.0) as num).toDouble(),
      avgRevenuePerPatient: ((map['avg_revenue_per_patient'] ?? 0.0) as num).toDouble(),
      newPatientsPercentage: ((map['new_patients_percentage'] ?? 0.0) as num).toDouble(),
      returningPatientsPercentage: ((map['returning_patients_percentage'] ?? 0.0) as num).toDouble(),
      byGender: Map<String, int>.from(map['by_gender'] ?? {}),
      byAgeGroup: Map<String, int>.from(map['by_age'] ?? {}),
      inactivePatients: ((map['inactive'] ?? []) as List)
          .map((p) => InactivePatientModel.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
