import 'package:flutter/material.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/reports_entities.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetRevenueSummaryUseCase {
  final IReportsRepository repository;

  GetRevenueSummaryUseCase(this.repository);

  Future<Either<Failure, RevenueSummaryEntity>> call({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) {
    return repository.getRevenueSummary(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
  }
}
