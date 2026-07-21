import 'package:flutter/material.dart';

class DoctorSchedulesEntity {
  final String id;
  final String clinicId;
  final String doctorId; // = user_id
  final int? dayOfWeek;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isActive;

  DoctorSchedulesEntity(
      {required this.id,
      required this.clinicId,
      required this.doctorId,
      required this.dayOfWeek,
      this.startTime,
      this.endTime,
      required this.isActive});
}
