// ────────────────────────────────────────────────────────
// GetFinancialReceivablesReportUseCase — استخدام جلب تقرير المستحقات المالية
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/reports/domain/entities/financial_receivables_entity.dart';
import 'package:clinic_pro/features/reports/domain/repositories/i_reports_repository.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetFinancialReceivablesReportUseCase {
  final IReportsRepository _repository;

  GetFinancialReceivablesReportUseCase(this._repository);

  Future<Either<Failure, FinancialReceivablesEntity>> call({
    String? ownerId,
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) {
    return _repository.getFinancialReceivablesReport(
      ownerId: ownerId,
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
  }
}
