import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import '../models/revenue_summary_model.dart';
import '../models/appointment_stats_model.dart';
import '../models/patient_stats_model.dart';
import '../models/doctor_performance_model.dart';
import '../models/template_stats_model.dart';
import '../models/drug_stats_model.dart';
import '../../domain/entities/clinic_report_entity.dart';
import '../../domain/entities/reports_entities.dart';
import 'i_reports_remote_data_source.dart';
import 'reports_cache_manager.dart';

@LazySingleton(as: IReportsRemoteDataSource)
class ReportsRpcRemoteDataSourceImpl implements IReportsRemoteDataSource {
  final ICloudService _cloudService;
  final ReportsCacheManager _cacheManager;

  ReportsRpcRemoteDataSourceImpl(this._cloudService, this._cacheManager);

  /// تحويل كائن النطاق الزمني والتواريخ المخصصة إلى تواريخ ISO للإرسال إلى RPC
  Map<String, dynamic> _buildDateParams({
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
  }) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (range) {
      case ReportsDateRange.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
        startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportsDateRange.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case ReportsDateRange.threeMonths:
        startDate = DateTime(now.year, now.month - 3, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case ReportsDateRange.custom:
        if (customDateRange != null) {
          startDate = customDateRange.start;
          endDate = DateTime(
            customDateRange.end.year,
            customDateRange.end.month,
            customDateRange.end.day,
            23,
            59,
            59,
          );
        }
        break;
    }

    return {
      'p_start_date': startDate?.toIso8601String(),
      'p_end_date': endDate?.toIso8601String(),
    };
  }

  @override
  Future<RevenueSummaryModel> fetchRevenueSummary({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'rev_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<RevenueSummaryModel>(cacheKey);
      if (cached != null) return cached;
    }

    final dateParams = _buildDateParams(range: range, customDateRange: customDateRange);
    final response = await _cloudService.rpc('get_financial_report_rpc', params: {
      'p_clinic_id': (clinicId != null && clinicId.isNotEmpty) ? clinicId : null,
      'p_doctor_id': (doctorId != null && doctorId.isNotEmpty) ? doctorId : null,
      ...dateParams,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final result = RevenueSummaryModel.fromMap(data);
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<AppointmentStatsModel> fetchAppointmentStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'appt_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<AppointmentStatsModel>(cacheKey);
      if (cached != null) return cached;
    }

    final dateParams = _buildDateParams(range: range, customDateRange: customDateRange);
    final response = await _cloudService.rpc('get_appointments_report_rpc', params: {
      'p_clinic_id': (clinicId != null && clinicId.isNotEmpty) ? clinicId : null,
      'p_doctor_id': (doctorId != null && doctorId.isNotEmpty) ? doctorId : null,
      ...dateParams,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final result = AppointmentStatsModel.fromMap(data);
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<PatientStatsModel> fetchPatientStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'pat_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<PatientStatsModel>(cacheKey);
      if (cached != null) return cached;
    }

    final dateParams = _buildDateParams(range: range, customDateRange: customDateRange);
    final response = await _cloudService.rpc('get_patient_stats_report_rpc', params: {
      'p_clinic_id': (clinicId != null && clinicId.isNotEmpty) ? clinicId : null,
      ...dateParams,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final result = PatientStatsModel.fromMap(data);
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<List<DoctorPerformanceModel>> fetchDoctorPerformance({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'doc_perf_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<List<DoctorPerformanceModel>>(cacheKey);
      if (cached != null) return cached;
    }

    final dateParams = _buildDateParams(range: range, customDateRange: customDateRange);
    final response = await _cloudService.rpc('get_doctors_performance_report_rpc', params: {
      'p_clinic_id': (clinicId != null && clinicId.isNotEmpty) ? clinicId : null,
      ...dateParams,
    });

    final List rawList = response is List ? response : [];
    final result = rawList
        .map((item) => DoctorPerformanceModel.fromMap(item as Map<String, dynamic>))
        .toList();
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<DrugStatsEntity> fetchDrugStats({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'drug_${doctorId ?? ''}_${clinicId ?? ''}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<DrugStatsEntity>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _cloudService.rpc('get_prescriptions_report_rpc', params: {
      'p_clinic_id': (clinicId != null && clinicId.isNotEmpty) ? clinicId : null,
      'p_doctor_id': (doctorId != null && doctorId.isNotEmpty) ? doctorId : null,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final result = DrugStatsModel.fromMap(data);
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<List<TemplateStatsModel>> fetchTemplateStats({
    String? doctorId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'tpl_${doctorId ?? ''}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<List<TemplateStatsModel>>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _cloudService.rpc('get_prescriptions_report_rpc', params: {
      'p_doctor_id': (doctorId != null && doctorId.isNotEmpty) ? doctorId : null,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final List rawTemplates = data['template_stats'] as List? ?? [];
    final result = rawTemplates
        .map((t) => TemplateStatsModel.fromMap(t as Map<String, dynamic>, percentage: ((t['percentage'] ?? 0.0) as num).toDouble()))
        .toList();
    _cacheManager.set(cacheKey, result);
    return result;
  }

  @override
  Future<ClinicReportEntity> fetchClinicReport(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'clinic_rpt_$ownerId';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<ClinicReportEntity>(cacheKey);
      if (cached != null) return cached;
    }

    final response = await _cloudService.rpc('get_clinics_report_rpc', params: {
      'p_owner_id': ownerId.isNotEmpty ? ownerId : null,
    });

    final Map<String, dynamic> data = (response is List && response.isNotEmpty)
        ? response.first as Map<String, dynamic>
        : (response is Map<String, dynamic> ? response : {});

    final List rawClinics = data['clinics'] as List? ?? [];
    final clinicsList = rawClinics.map((c) {
      final map = c as Map<String, dynamic>;
      final col = (map['collected_amount'] as num? ?? 0.0).toDouble();
      final exp = (map['expenses'] as num? ?? 0.0).toDouble();
      final expected = (map['expected_revenue'] as num? ?? 0.0).toDouble();
      final net = (map['net_profit'] as num? ?? 0.0).toDouble();
      final docs = (map['number_of_doctors'] as num? ?? 1).toInt();
      final denominator = col > 0 ? col : (expected > 0 ? expected : 1.0);
      final margin = (net / denominator) * 100;
      final revPerDoc = docs > 0 ? col / docs : col;

      return ClinicComparisonItem(
        clinicId: map['id'] as String? ?? '',
        clinicName: map['name'] as String? ?? '',
        expectedRevenue: expected,
        collectedAmount: col,
        monthlyExpenses: exp,
        netProfit: net,
        profitMargin: margin,
        dayAppointments: (map['day_appointments'] as num? ?? 0).toInt(),
        finishedAppointments: (map['finished_appointments'] as num? ?? 0).toInt(),
        numberOfDoctors: docs,
        revenuePerDoctor: revPerDoc,
        monthlyPerformance: const [],
        monthlyExpectedPerformance: const [],
      );
    }).toList();

    final result = ClinicReportEntity(
      totalActiveClinics: (data['total_active_clinics'] as num? ?? 0).toInt(),
      totalExpectedRevenue: (data['total_expected_revenue'] as num? ?? 0.0).toDouble(),
      totalCollectedAmount: (data['total_collected_amount'] as num? ?? 0.0).toDouble(),
      totalExpenses: (data['total_expenses'] as num? ?? 0.0).toDouble(),
      totalNetProfit: (data['total_net_profit'] as num? ?? 0.0).toDouble(),
      totalAppointmentsToday: (data['total_appointments_today'] as num? ?? 0).toInt(),
      totalDoctors: (data['total_doctors'] as num? ?? 0).toInt(),
      clinics: clinicsList,
    );
    _cacheManager.set(cacheKey, result);
    return result;
  }
}
