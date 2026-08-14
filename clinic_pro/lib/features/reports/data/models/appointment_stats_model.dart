import '../../domain/entities/reports_entities.dart';

class PeakHourModel extends PeakHourEntity {
  const PeakHourModel({required super.hour, required super.count});

  factory PeakHourModel.fromMap(Map<String, dynamic> map) {
    return PeakHourModel(
      hour: map['hour'] as int,
      count: map['count'] as int,
    );
  }
}

class PeakDayModel extends PeakDayEntity {
  const PeakDayModel({required super.dayName, required super.count});

  factory PeakDayModel.fromMap(Map<String, dynamic> map) {
    return PeakDayModel(
      dayName: map['day'] as String,
      count: map['count'] as int,
    );
  }
}

class VisitTypeModel extends VisitTypeEntity {
  const VisitTypeModel({required super.name, required super.count});

  factory VisitTypeModel.fromMap(Map<String, dynamic> map) {
    return VisitTypeModel(
      name: map['name'] as String,
      count: map['count'] as int,
    );
  }
}

class AppointmentStatsModel extends AppointmentStatsEntity {
  const AppointmentStatsModel({
    required super.totalAppointments,
    required super.completedAppointments,
    required super.cancelledAppointments,
    required super.attendanceRate,
    super.avgWaitTimeMinutes = 0,
    super.urgentCount = 0,
    super.urgentPercentage = 0.0,
    super.noShowCount = 0,
    super.noShowRate = 0.0,
    super.statusBreakdown = const {},
    required super.peakHours,
    required super.peakDays,
    required super.byType,
  });

  factory AppointmentStatsModel.empty() {
    return const AppointmentStatsModel(
      totalAppointments: 0,
      completedAppointments: 0,
      cancelledAppointments: 0,
      attendanceRate: 0.0,
      avgWaitTimeMinutes: 0,
      urgentCount: 0,
      urgentPercentage: 0.0,
      noShowCount: 0,
      noShowRate: 0.0,
      statusBreakdown: {},
      peakHours: [],
      peakDays: [],
      byType: [],
    );
  }

  factory AppointmentStatsModel.fromMap(Map<String, dynamic> map) {
    return AppointmentStatsModel(
      totalAppointments: (map['total'] ?? 0) as int,
      completedAppointments: (map['completed'] ?? 0) as int,
      cancelledAppointments: (map['cancelled'] ?? 0) as int,
      attendanceRate: ((map['attendance_rate'] ?? 0.0) as num).toDouble(),
      avgWaitTimeMinutes: (map['avg_wait_time'] ?? 0) as int,
      urgentCount: (map['urgent_count'] ?? 0) as int,
      urgentPercentage: ((map['urgent_percentage'] ?? 0.0) as num).toDouble(),
      noShowCount: (map['no_show_count'] ?? 0) as int,
      noShowRate: ((map['no_show_rate'] ?? 0.0) as num).toDouble(),
      statusBreakdown: Map<String, int>.from(map['status_breakdown'] ?? {}),
      peakHours: ((map['peak_hours'] ?? []) as List)
          .map((h) => PeakHourModel.fromMap(h as Map<String, dynamic>))
          .toList(),
      peakDays: ((map['peak_days'] ?? []) as List)
          .map((d) => PeakDayModel.fromMap(d as Map<String, dynamic>))
          .toList(),
      byType: ((map['by_type'] ?? []) as List)
          .map((t) => VisitTypeModel.fromMap(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
