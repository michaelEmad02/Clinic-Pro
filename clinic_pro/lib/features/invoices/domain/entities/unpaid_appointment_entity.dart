// ────────────────────────────────────────────────────────
// UnpaidAppointmentEntity — كيان المواعيد غير المدفوعة بالكامل للمريض
// يُستخدم عند اختيار الموعد بداخل شيت إضافة الفاتورة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class UnpaidAppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String clinicId;
  final String? doctorId;
  final String? appointmentTypeName;
  final double expectedPrice;
  final double paidSoFar;
  final String date;
  final String time;

  const UnpaidAppointmentEntity({
    required this.id,
    required this.patientId,
    required this.clinicId,
    this.doctorId,
    this.appointmentTypeName,
    required this.expectedPrice,
    this.paidSoFar = 0.0,
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        clinicId,
        doctorId,
        appointmentTypeName,
        expectedPrice,
        paidSoFar,
        date,
        time,
      ];
}
