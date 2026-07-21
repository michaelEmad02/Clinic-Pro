// ────────────────────────────────────────────────────────
// كيان ساعات عمل الطبيب (DoctorScheduleEntity)
// يمثل مواعيد عمل الطبيب في عيادة محددة خلال أيام الأسبوع
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class DoctorScheduleEntity extends Equatable {
  final String id;
  final String doctorId;
  final String clinicId;
  final int dayOfWeek; // من 0 (السبت) إلى 6 (الجمعة)
  final String startTime; // مثل: "09:00"
  final String endTime; // مثل: "17:00"

  const DoctorScheduleEntity({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props =>
      [id, doctorId, clinicId, dayOfWeek, startTime, endTime];
}
