import 'package:flutter/material.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import '../models/revenue_summary_model.dart';
import '../models/appointment_stats_model.dart';
import '../models/patient_stats_model.dart';
import '../models/doctor_performance_model.dart';
import '../models/template_stats_model.dart';
import '../models/financial_receivables_model.dart';
import '../../domain/entities/clinic_report_entity.dart';
import '../../domain/entities/reports_entities.dart';

abstract class IReportsRemoteDataSource {
  Future<RevenueSummaryModel> fetchRevenueSummary({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<AppointmentStatsModel> fetchAppointmentStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<PatientStatsModel> fetchPatientStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<List<DoctorPerformanceModel>> fetchDoctorPerformance({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
  Future<DrugStatsEntity> fetchDrugStats({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  });
  Future<List<TemplateStatsModel>> fetchTemplateStats({
    String? doctorId,
    bool forceRefresh = false,
  });
  Future<ClinicReportEntity> fetchClinicReport(
    String ownerId, {
    bool forceRefresh = false,
  });
  Future<FinancialReceivablesModel> fetchFinancialReceivablesReport({
    String? ownerId,
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  });
}

