import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../entities/reports_entities.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetDoctorPerformanceUseCase {
  final IReportsRepository repository;

  GetDoctorPerformanceUseCase(this.repository);

  Future<Either<Failure, List<DoctorPerformanceEntity>>> call({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) {
    return repository.getDoctorPerformance(
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
  }
}
