import '../../domain/entities/reports_entities.dart';

class DoctorPerformanceModel extends DoctorPerformanceEntity {
  const DoctorPerformanceModel({
    required super.doctorId,
    required super.doctorName,
    required super.visitCount,
    required super.revenue,
    required super.rating,
    required super.trend,
    super.avatarUrl,
  });

  factory DoctorPerformanceModel.fromMap(Map<String, dynamic> map) {
    return DoctorPerformanceModel(
      doctorId: map['doctor_id'] as String,
      doctorName: map['doctor_name'] as String,
      visitCount: map['visit_count'] as int? ?? map['patient_count'] as int? ?? 0,
      revenue: (map['revenue'] as num).toDouble(),
      rating: map['rating'] as int,
      trend: map['trend'] as String,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}
