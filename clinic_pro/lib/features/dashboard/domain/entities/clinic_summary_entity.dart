// ─────────────────────────────────────────
// Entity ملخص العيادة المعروضة في لوحة التحكم
// يمثل بيانات عيادة مختصرة مع إحصائياتها
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ClinicSummaryEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final int doctorsCount;
  final int patientsCount;
  final bool isActive;

  const ClinicSummaryEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.doctorsCount,
    required this.patientsCount,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, location, doctorsCount, patientsCount, isActive];
}
