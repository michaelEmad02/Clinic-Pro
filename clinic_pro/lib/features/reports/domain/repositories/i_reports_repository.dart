import 'package:flutter/material.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:dartz/dartz.dart';
import '../entities/reports_entities.dart';
import '../entities/clinic_report_entity.dart';

abstract class IReportsRepository {
  Future<Either<Failure, RevenueSummaryEntity>> getRevenueSummary({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<Either<Failure, AppointmentStatsEntity>> getAppointmentStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<Either<Failure, PatientStatsEntity>> getPatientStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<Either<Failure, List<DoctorPerformanceEntity>>> getDoctorPerformance({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<Either<Failure, DrugStatsEntity>> getDrugStats({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, List<TemplateStatsEntity>>> getTemplateStats({
    String? doctorId,
    bool forceRefresh = false,
  });
  Future<Either<Failure, ClinicReportEntity>> getClinicReport(
    String ownerId, {
    bool forceRefresh = false,
  });
}

