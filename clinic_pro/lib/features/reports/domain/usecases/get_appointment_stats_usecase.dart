import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import '../entities/reports_entities.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetAppointmentStatsUseCase {
  final IReportsRepository repository;

  GetAppointmentStatsUseCase(this.repository);

  Future<Either<Failure, AppointmentStatsEntity>> call({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) {
    return repository.getAppointmentStats(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
  }
}
