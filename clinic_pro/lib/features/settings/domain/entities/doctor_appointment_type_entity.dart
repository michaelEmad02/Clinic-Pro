// ────────────────────────────────────────────────────────
// كيان تسعيرة زيارة الطبيب (DoctorAppointmentTypeEntity)
// يمثل تسعيرة كشف محدد للطبيب في عيادة معينة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class DoctorAppointmentTypeEntity extends Equatable {
  final String id;
  final String doctorId;
  final String? clinicId; // Null يعني صالح لجميع العيادات
  final String appointmentTypeId;
  final String? name; // اسم الزيارة (كشف عادي، استشارة...)
  final double price;

  const DoctorAppointmentTypeEntity({
    required this.id,
    required this.doctorId,
    this.clinicId,
    required this.appointmentTypeId,
    this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, doctorId, clinicId, appointmentTypeId, name, price];
}
