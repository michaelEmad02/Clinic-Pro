// ────────────────────────────────────────────────────────
// UnpaidAppointmentEntity — كيان المواعيد غير المدفوعة بالكامل للمريض
// يُستخدم عند اختيار الموعد بداخل شيت إضافة الفاتورة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class UnpaidAppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String? patientName;
  final String clinicId;
  final String? doctorId;
  final String? doctorName;
  final String? appointmentTypeName;
  final double expectedPrice;
  final double paidSoFar;
  final String date;
  final String time;

  const UnpaidAppointmentEntity({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.clinicId,
    this.doctorId,
    this.doctorName,
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
        patientName,
        clinicId,
        doctorId,
        doctorName,
        appointmentTypeName,
        expectedPrice,
        paidSoFar,
        date,
        time,
      ];
}
