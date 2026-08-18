import 'package:flutter/material.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/patients/data/models/patient_model.dart';
import 'package:clinic_pro/features/appointments/data/models/appointment_model.dart';
import 'package:clinic_pro/features/invoices/data/models/invoice_model.dart';

import 'package:clinic_pro/core/enities/performance_statistics.dart';
import '../../domain/entities/clinic_report_entity.dart';
import '../../domain/entities/reports_entities.dart';
import 'i_reports_remote_data_source.dart';
import '../../presentation/manager/reports_state.dart';
import '../models/revenue_summary_model.dart';
import '../models/appointment_stats_model.dart';
import '../models/patient_stats_model.dart';
import '../models/doctor_performance_model.dart';
import '../models/template_stats_model.dart';
import '../../../../core/utils/date_range_helper.dart';

import 'reports_cache_manager.dart';

// @LazySingleton(as: IReportsRemoteDataSource)
class ReportsRemoteDataSourceImpl implements IReportsRemoteDataSource {
  final ICloudService _cloudService;
  final ReportsCacheManager _cacheManager;

  ReportsRemoteDataSourceImpl(this._cloudService, this._cacheManager);

  // ────────────────────────────────────────────────────────
  // الأعمدة المطلوبة فقط لكل جدول — لتقليل حجم البيانات المنقولة
  // ────────────────────────────────────────────────────────
  static const _apptColumns = '*';
  static const _invoiceColumns = '*';
  static const _expenseColumns = '*';
  static const _patientColumns = '*';
  static const _drugColumns = '*';
  static const _prescriptionColumns = '*';
  static const _prescriptionItemColumns = '*';

  // ────────────────────────────────────────────────────────
  // fetchRevenueSummary
  // ────────────────────────────────────────────────────────
  @override
  Future<RevenueSummaryModel> fetchRevenueSummary({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'rev_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<RevenueSummaryModel>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final dateHelper = DateRangeHelper.fromRange(
        range: range,
        customDateRange: customDateRange,
      );

      // ── جلب المواعيد مع فلترة server-side بالتاريخ ──
      final Map<String, dynamic> apptEq = {};
      if (doctorId != null && doctorId.isNotEmpty) apptEq['doctor_id'] = doctorId;
      if (clinicId != null && clinicId.isNotEmpty) apptEq['clinic_id'] = clinicId;

      final apptsRaw = await _cloudService.select(
        table: SupabaseTables.appointments,
        eq: apptEq.isNotEmpty ? apptEq : null,
        gte: {'created_at': dateHelper.rangeStartUtcIso},
        lte: {'created_at': dateHelper.rangeEndUtcIso},
      );

      // ── جلب الفواتير ──
      final Map<String, dynamic> invEq = {};
      if (clinicId != null && clinicId.isNotEmpty) invEq['clinic_id'] = clinicId;

      final invoicesRaw = await _cloudService.select(
        table: SupabaseTables.invoices,
        eq: invEq.isNotEmpty ? invEq : null,
        gte: {'created_at': dateHelper.rangeStartUtcIso},
        lte: {'created_at': dateHelper.rangeEndUtcIso},
      );

      // ── جلب المصروفات ──
      final expensesRaw = await _cloudService.select(
        table: SupabaseTables.expenses,
        gte: {'created_at': dateHelper.rangeStartUtcIso},
        lte: {'created_at': dateHelper.rangeEndUtcIso},
      );

      final appts =
          apptsRaw.map((raw) => AppointmentModel.fromJson(raw)).toList();

      List<InvoiceModel> allInvoices =
          invoicesRaw.map((raw) => InvoiceModel.fromJson(raw)).toList();

      if (doctorId != null && doctorId.isNotEmpty) {
        final doctorApptIds = appts.map((a) => a.id).toSet();
        allInvoices = allInvoices
            .where((inv) => doctorApptIds.contains(inv.sourceId))
            .toList();
      }

      final allValidAppts =
          appts.where((a) => a.status != AppointmentStatus.cancelled).toList();

      final now = DateTime.now();

      // ── فلترة البيانات بالنطاق الزمني ──
      final validAppts =
          allValidAppts.where((a) => dateHelper.inRange(a.createdAt)).toList();
      final invoices =
          allInvoices.where((inv) => dateHelper.inRange(inv.createdAt)).toList();
      final filteredExpensesRaw = expensesRaw.where((exp) {
        final cStr = exp['created_at'] as String?;
        if (cStr == null) return false;
        final dt = DateTime.tryParse(cStr);
        return dt != null && dateHelper.inRange(dt);
      }).toList();

      // ── حساب الإجماليات بعد الفلترة ──
      final totalRevenue = validAppts.fold<double>(
        0.0,
        (sum, a) =>
            sum +
            ((a.invoiceAmount as num?)?.toDouble() ??
                (a.price as num).toDouble()),
      );

      final collectedAmount = invoices.fold<double>(
        0.0,
        (sum, inv) => sum + inv.paidAmount,
      );

      final totalExpenses = doctorId != null
          ? 0.0
          : filteredExpensesRaw.fold<double>(
              0.0,
              (sum, exp) => sum + ((exp['amount'] ?? 0.0) as num).toDouble(),
            );

      final pendingAmount = invoices.fold<double>(
        0.0,
        (sum, inv) => sum + inv.remainingAmount,
      );

      // Dynamic chart grouping according to selected ReportsDateRange
      List<WeeklyRevenueModel> chart = [];

      if (range == ReportsDateRange.custom && customDateRange != null) {
        final start = customDateRange.start;
        final end = customDateRange.end;
        final differenceInDays = end.difference(start).inDays;

        if (differenceInDays <= 14) {
          for (int i = 0; i <= differenceInDays; i++) {
            final dayDt = start.add(Duration(days: i));
            final label = '${dayDt.day}/${dayDt.month}';

            final dayAppts = validAppts.where((a) =>
                a.createdAt.year == dayDt.year &&
                a.createdAt.month == dayDt.month &&
                a.createdAt.day == dayDt.day);
            final dayInvoices = allInvoices.where((inv) =>
                inv.createdAt.year == dayDt.year &&
                inv.createdAt.month == dayDt.month &&
                inv.createdAt.day == dayDt.day);

            final dRevenue = dayAppts.fold<double>(
                0.0,
                (s, a) =>
                    s +
                    ((a.invoiceAmount as num?)?.toDouble() ??
                        (a.price as num).toDouble()));
            final dCollected =
                dayInvoices.fold<double>(0.0, (s, inv) => s + inv.paidAmount);

            double dExpenses = 0.0;
            if (doctorId == null) {
              for (var exp in expensesRaw) {
                final cStr = exp['created_at'] as String?;
                if (cStr != null) {
                  final eDt = DateTime.tryParse(cStr);
                  if (eDt != null &&
                      eDt.year == dayDt.year &&
                      eDt.month == dayDt.month &&
                      eDt.day == dayDt.day) {
                    dExpenses += ((exp['amount'] ?? 0.0) as num).toDouble();
                  }
                }
              }
            }

            chart.add(WeeklyRevenueModel(
              week: label,
              revenue: dRevenue,
              collected: dCollected,
              expenses: dExpenses,
            ));
          }
        } else {
          DateTime current = DateTime(start.year, start.month, 1);
          while (current.isBefore(end) ||
              (current.year == end.year && current.month == end.month)) {
            final monthName = AppStrings.fullMonths[current.month - 1];

            final monthAppts = validAppts.where((a) =>
                a.createdAt.month == current.month &&
                a.createdAt.year == current.year);
            final monthInvoices = allInvoices.where((inv) =>
                inv.createdAt.month == current.month &&
                inv.createdAt.year == current.year);

            final mRevenue = monthAppts.fold<double>(
                0.0,
                (s, a) =>
                    s +
                    ((a.invoiceAmount as num?)?.toDouble() ??
                        (a.price as num).toDouble()));
            final mCollected =
                monthInvoices.fold<double>(0.0, (s, inv) => s + inv.paidAmount);

            double mExpenses = 0.0;
            if (doctorId == null) {
              for (var exp in expensesRaw) {
                final cStr = exp['created_at'] as String?;
                if (cStr != null) {
                  final eDt = DateTime.tryParse(cStr);
                  if (eDt != null &&
                      eDt.month == current.month &&
                      eDt.year == current.year) {
                    mExpenses += ((exp['amount'] ?? 0.0) as num).toDouble();
                  }
                }
              }
            }

            chart.add(WeeklyRevenueModel(
              week: monthName,
              revenue: mRevenue,
              collected: mCollected,
              expenses: mExpenses,
            ));

            current = DateTime(current.year, current.month + 1, 1);
          }
        }
      } else if (range == ReportsDateRange.threeMonths ||
          range == ReportsDateRange.custom) {
        for (int i = 2; i >= 0; i--) {
          final dt = DateTime(now.year, now.month - i, 1);
          final monthName = AppStrings.fullMonths[dt.month - 1];

          final monthAppts = validAppts.where((a) =>
              a.createdAt.month == dt.month && a.createdAt.year == dt.year);
          final monthInvoices = allInvoices.where((inv) =>
              inv.createdAt.month == dt.month && inv.createdAt.year == dt.year);

          final mRevenue = monthAppts.fold<double>(
              0.0,
              (s, a) =>
                  s +
                  ((a.invoiceAmount as num?)?.toDouble() ??
                      (a.price as num).toDouble()));
          final mCollected =
              monthInvoices.fold<double>(0.0, (s, inv) => s + inv.paidAmount);

          double mExpenses = 0.0;
          if (doctorId == null) {
            for (var exp in expensesRaw) {
              final cStr = exp['created_at'] as String?;
              if (cStr != null) {
                final eDt = DateTime.tryParse(cStr);
                if (eDt != null &&
                    eDt.month == dt.month &&
                    eDt.year == dt.year) {
                  mExpenses += ((exp['amount'] ?? 0.0) as num).toDouble();
                }
              }
            }
          }

          chart.add(WeeklyRevenueModel(
            week: monthName,
            revenue: mRevenue,
            collected: mCollected,
            expenses: mExpenses,
          ));
        }
      } else if (range == ReportsDateRange.thisWeek) {
        // بداية الأسبوع = السبت (weekday 6 في Dart)
        final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
        final startOfWeek = now.subtract(Duration(days: daysSinceSaturday));

        for (int i = 0; i < 7; i++) {
          final dayDt = startOfWeek.add(Duration(days: i));
          final label = AppStrings.dayNames[i];

          final dayAppts = validAppts.where((a) =>
              a.createdAt.year == dayDt.year &&
              a.createdAt.month == dayDt.month &&
              a.createdAt.day == dayDt.day);
          final dayInvoices = allInvoices.where((inv) =>
              inv.createdAt.year == dayDt.year &&
              inv.createdAt.month == dayDt.month &&
              inv.createdAt.day == dayDt.day);

          final dRevenue = dayAppts.fold<double>(
              0.0,
              (s, a) =>
                  s +
                  ((a.invoiceAmount as num?)?.toDouble() ??
                      (a.price as num).toDouble()));
          final dCollected =
              dayInvoices.fold<double>(0.0, (s, inv) => s + inv.paidAmount);

          double dExpenses = 0.0;
          if (doctorId == null) {
            for (var exp in expensesRaw) {
              final cStr = exp['created_at'] as String?;
              if (cStr != null) {
                final eDt = DateTime.tryParse(cStr);
                if (eDt != null &&
                    eDt.year == dayDt.year &&
                    eDt.month == dayDt.month &&
                    eDt.day == dayDt.day) {
                  dExpenses += ((exp['amount'] ?? 0.0) as num).toDouble();
                }
              }
            }
          }

          chart.add(WeeklyRevenueModel(
            week: label,
            revenue: dRevenue,
            collected: dCollected,
            expenses: dExpenses,
          ));
        }
      } else {
        // Default: thisMonth (Weeks 1 to 4)
        final currentMonthInvoices = allInvoices.where((i) =>
            i.createdAt.month == now.month && i.createdAt.year == now.year);
        final currentMonthAppts = validAppts.where((a) =>
            a.createdAt.month == now.month && a.createdAt.year == now.year);

        final Map<int, double> weeklyRevenueMap = {
          1: 0.0,
          2: 0.0,
          3: 0.0,
          4: 0.0
        };
        final Map<int, double> weeklyCollectedMap = {
          1: 0.0,
          2: 0.0,
          3: 0.0,
          4: 0.0
        };
        final Map<int, double> weeklyExpensesMap = {
          1: 0.0,
          2: 0.0,
          3: 0.0,
          4: 0.0
        };

        for (var a in currentMonthAppts) {
          final day = a.createdAt.day;
          final weekIndex = day <= 7
              ? 1
              : day <= 14
                  ? 2
                  : day <= 21
                      ? 3
                      : 4;
          final amt = (a.invoiceAmount as num?)?.toDouble() ??
              (a.price as num).toDouble();
          weeklyRevenueMap[weekIndex] =
              (weeklyRevenueMap[weekIndex] ?? 0.0) + amt;
        }

        for (var inv in currentMonthInvoices) {
          final day = inv.createdAt.day;
          final weekIndex = day <= 7
              ? 1
              : day <= 14
                  ? 2
                  : day <= 21
                      ? 3
                      : 4;
          weeklyCollectedMap[weekIndex] =
              (weeklyCollectedMap[weekIndex] ?? 0.0) + inv.paidAmount;
        }

        if (doctorId == null) {
          for (var exp in expensesRaw) {
            final cStr = exp['created_at'] as String?;
            if (cStr != null) {
              final dt = DateTime.tryParse(cStr);
              if (dt != null && dt.month == now.month && dt.year == now.year) {
                final day = dt.day;
                final weekIndex = day <= 7
                    ? 1
                    : day <= 14
                        ? 2
                        : day <= 21
                            ? 3
                            : 4;
                weeklyExpensesMap[weekIndex] =
                    (weeklyExpensesMap[weekIndex] ?? 0.0) +
                        ((exp['amount'] ?? 0.0) as num).toDouble();
              }
            }
          }
        }

        chart = [1, 2, 3, 4].map((w) {
          return WeeklyRevenueModel(
            week: AppStrings.isArabic ? 'الأسبوع $w' : 'Week $w',
            revenue: weeklyRevenueMap[w] ?? 0.0,
            collected: weeklyCollectedMap[w] ?? 0.0,
            expenses: weeklyExpensesMap[w] ?? 0.0,
          );
        }).toList();
      }

      final Map<String, double> categorySums = {};
      if (doctorId == null) {
        for (var exp in expensesRaw) {
          final cat = (exp['category'] ??
                  exp['category_name'] ??
                  (AppStrings.isArabic ? 'أخرى' : 'Other'))
              .toString();
          final amount = ((exp['amount'] ?? 0.0) as num).toDouble();
          categorySums[cat] = (categorySums[cat] ?? 0.0) + amount;
        }
      }

      final totalExp = categorySums.values.fold<double>(0.0, (s, a) => s + a);
      final expensesBreakdown = categorySums.entries.map((e) {
        return ExpenseCategoryStatModel(
          category: e.key,
          amount: e.value,
          percentage: totalExp > 0 ? (e.value / totalExp * 100) : 0.0,
        );
      }).toList();

      final currentMonthInvoices = allInvoices.where((i) =>
          i.createdAt.month == now.month && i.createdAt.year == now.year);
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final prevMonthInvoices = allInvoices.where((i) =>
          i.createdAt.month == prevMonth && i.createdAt.year == prevYear);

      final currRev =
          currentMonthInvoices.fold<double>(0.0, (s, i) => s + i.paidAmount);
      final prevRev =
          prevMonthInvoices.fold<double>(0.0, (s, i) => s + i.paidAmount);

      String revenueChange = '0%';
      if (prevRev > 0) {
        final pct = ((currRev - prevRev) / prevRev * 100).round();
        revenueChange = '${pct >= 0 ? '+' : ''}$pct%';
      } else if (currRev > 0) {
        revenueChange = '+100%';
      }

      final result = RevenueSummaryModel(
        totalRevenue: totalRevenue,
        collectedAmount: collectedAmount,
        totalExpenses: totalExpenses,
        netProfit: collectedAmount - totalExpenses,
        pendingAmount: pendingAmount,
        revenueChange: revenueChange,
        expensesChange: '0%',
        chart: chart,
        expensesBreakdown: expensesBreakdown,
      );
      _cacheManager.set(cacheKey, result);
      return result;
    } catch (_) {
      return RevenueSummaryModel.empty();
    }
  }

  // ────────────────────────────────────────────────────────
  // fetchAppointmentStats
  // ────────────────────────────────────────────────────────
  @override
  Future<AppointmentStatsModel> fetchAppointmentStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'appt_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<AppointmentStatsModel>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final dateHelper = DateRangeHelper.fromRange(
        range: range,
        customDateRange: customDateRange,
      );

      final Map<String, dynamic> eq = {};
      if (doctorId != null && doctorId.isNotEmpty) {
        eq['doctor_id'] = doctorId;
      }
      if (clinicId != null && clinicId.isNotEmpty) {
        eq['clinic_id'] = clinicId;
      }

      final apptsRaw = await _cloudService.select(
        table: SupabaseTables.appointments,
        eq: eq.isNotEmpty ? eq : null,
        gte: {'created_at': dateHelper.rangeStartUtcIso},
        lte: {'created_at': dateHelper.rangeEndUtcIso},
      );

      if (apptsRaw.isNotEmpty) {
        final allAppointments =
            apptsRaw.map((raw) => AppointmentModel.fromJson(raw)).toList();

        final appointments = allAppointments.where((a) => dateHelper.inRange(a.createdAt)).toList();

        final now = DateTime.now();
        final total = appointments.length;
        final completed = appointments
            .where((a) => a.status == AppointmentStatus.confirmed)
            .length;
        final cancelled = appointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .length;
        final attendanceRate = total > 0 ? (completed / total * 100) : 0.0;

        // 1. Average Wait Time (arrivedAt -> calledAt)
        int totalWaitMinutes = 0;
        int waitCount = 0;
        for (var a in appointments) {
          if (a.arrivedAt != null && a.calledAt != null) {
            final diff = a.calledAt!.difference(a.arrivedAt!).inMinutes;
            if (diff >= 0) {
              totalWaitMinutes += diff;
              waitCount++;
            }
          }
        }
        final avgWaitTime = waitCount > 0 ? (totalWaitMinutes / waitCount).round() : 0;

        // 2. Urgent Appointments Stats
        final urgentCount = appointments.where((a) => a.isUrgent).length;
        final urgentPercentage = total > 0 ? (urgentCount / total * 100) : 0.0;

        // 3. No-Show Stats (scheduled appointments with past date)
        final noShowCount = appointments.where((a) {
          if (a.status != AppointmentStatus.scheduled) return false;
          final apptDate = DateTime.tryParse(a.date);
          return apptDate != null && apptDate.isBefore(DateTime(now.year, now.month, now.day));
        }).length;
        final noShowRate = total > 0 ? (noShowCount / total * 100) : 0.0;

        // 4. Status Breakdown
        final Map<String, int> statusBreakdown = {
          AppointmentStatus.scheduled: 0,
          AppointmentStatus.confirmed: 0,
          AppointmentStatus.inProgress: 0,
          AppointmentStatus.done: 0,
          AppointmentStatus.cancelled: 0,
        };
        for (var a in appointments) {
          statusBreakdown[a.status] = (statusBreakdown[a.status] ?? 0) + 1;
        }

        // Dynamic Peak Hours
        final Map<int, int> hourCounts = {};
        for (var a in appointments) {
          final dt = DateTime.tryParse(a.date);
          if (dt != null) {
            final h = dt.hour > 0 ? dt.hour : 10;
            hourCounts[h] = (hourCounts[h] ?? 0) + 1;
          }
        }
        final peakHours = hourCounts.entries
            .map((e) => {'hour': e.key, 'count': e.value})
            .toList();

        // Dynamic Peak Days
        final Map<String, int> dayCounts = {};

        for (var a in appointments) {
          final dt = DateTime.tryParse(a.date);
          if (dt != null) {
            // dt.weekday: 1=Mon..7=Sun → dayNames index: 0=Sat..6=Fri
            final dayIndex = (dt.weekday + 1) % 7;
            final dayName = AppStrings.dayNames[dayIndex];
            dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
          }
        }
        final peakDays = dayCounts.entries
            .map((e) => {'day': e.key, 'count': e.value})
            .toList();

        // Dynamic Visit Types
        final Map<String, String> typeNamesMap = {};
        try {
          final globalTypesRaw = await _cloudService.select(table: SupabaseTables.appointmentTypes);
          final globalTypesMap = <String, String>{
            for (var t in globalTypesRaw)
              if (t['id'] != null && t['name'] != null) (t['id'] as String): (t['name'] as String)
          };

          final docTypesRaw = await _cloudService.select(table: SupabaseTables.doctorAppointmentTypes);
          for (var dt in docTypesRaw) {
            final docTypeId = dt['id'] as String?;
            final apptTypeId = dt['appointment_type_id'] as String?;
            if (docTypeId != null && apptTypeId != null && globalTypesMap.containsKey(apptTypeId)) {
              typeNamesMap[docTypeId] = globalTypesMap[apptTypeId]!;
            }
          }
        } catch (_) {}

        final Map<String, int> typeCounts = {};
        for (var a in appointments) {
          final name = a.typeName ??
              typeNamesMap[a.typeId] ??
              (AppStrings.isArabic ? 'كشف عادي' : 'Regular Visit');
          typeCounts[name] = (typeCounts[name] ?? 0) + 1;
        }
        final byType = typeCounts.entries
            .map((e) => {'name': e.key, 'count': e.value})
            .toList();

        final result = AppointmentStatsModel.fromMap({
          'total': total,
          'completed': completed,
          'cancelled': cancelled,
          'attendance_rate': attendanceRate,
          'avg_wait_time': avgWaitTime,
          'urgent_count': urgentCount,
          'urgent_percentage': urgentPercentage,
          'no_show_count': noShowCount,
          'no_show_rate': noShowRate,
          'status_breakdown': statusBreakdown,
          'peak_hours': peakHours,
          'peak_days': peakDays,
          'by_type': byType,
        });
        _cacheManager.set(cacheKey, result);
        return result;
      }
    } catch (_) {}

    return AppointmentStatsModel.empty();
  }

  // ────────────────────────────────────────────────────────
  // fetchPatientStats
  // ────────────────────────────────────────────────────────
  @override
  Future<PatientStatsModel> fetchPatientStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'pat_${doctorId ?? ''}_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<PatientStatsModel>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final dateHelper = DateRangeHelper.fromRange(
        range: range,
        customDateRange: customDateRange,
      );

      final Map<String, dynamic> apptEq = {};
      if (doctorId != null && doctorId.isNotEmpty) apptEq['doctor_id'] = doctorId;
      if (clinicId != null && clinicId.isNotEmpty) apptEq['clinic_id'] = clinicId;

      final apptsRaw = await _cloudService.select(
        table: SupabaseTables.appointments,
        eq: apptEq.isNotEmpty ? apptEq : null,
        gte: {'created_at': dateHelper.rangeStartUtcIso},
        lte: {'created_at': dateHelper.rangeEndUtcIso},
      );
      final appts =
          apptsRaw.map((raw) => AppointmentModel.fromJson(raw)).toList();

      final now = DateTime.now();

      // ── جلب المرضى بأعمدة محددة فقط ──
      final patientsRaw = await _cloudService.select(
        table: SupabaseTables.patients,
        columns: _patientColumns,
      );
      if (patientsRaw.isNotEmpty) {
        final allPatients =
            patientsRaw.map((raw) => PatientModel.fromJson(raw)).toList();

        // If clinic or doctor specified, or date range, identify relevant patients from filtered appointments
        final Map<String, int> patientApptCounts = {};
        final Map<String, DateTime> patientLastVisits = {};

        for (var appt in appts) {
          final apptDt = DateTime.tryParse(appt.date) ?? appt.createdAt;

          patientApptCounts[appt.patientId] =
              (patientApptCounts[appt.patientId] ?? 0) + 1;
          final last = patientLastVisits[appt.patientId];
          if (last == null || apptDt.isAfter(last)) {
            patientLastVisits[appt.patientId] = apptDt;
          }
        }

        final bool hasFilter = (doctorId != null && doctorId.isNotEmpty) ||
            (clinicId != null && clinicId.isNotEmpty);

        final targetPatients = hasFilter
            ? allPatients.where((p) => patientApptCounts.containsKey(p.id)).toList()
            : allPatients;

        int males = 0;
        int females = 0;
        final Map<String, int> ageGroups = {
          '0-18': 0,
          '19-35': 0,
          '36-50': 0,
          '51-65': 0,
          '65+': 0,
        };

        for (var p in targetPatients) {
          final gender = p.gender;
          if (gender == Gender.male) {
            males++;
          } else if (gender == Gender.female) {
            females++;
          }

          int age = 30;
          if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
            final birthDate = DateTime.tryParse(p.dateOfBirth!);
            if (birthDate != null) {
              age = now.year - birthDate.year;
            }
          }

          if (age <= 18) {
            ageGroups['0-18'] = (ageGroups['0-18'] ?? 0) + 1;
          } else if (age <= 35) {
            ageGroups['19-35'] = (ageGroups['19-35'] ?? 0) + 1;
          } else if (age <= 50) {
            ageGroups['36-50'] = (ageGroups['36-50'] ?? 0) + 1;
          } else if (age <= 65) {
            ageGroups['51-65'] = (ageGroups['51-65'] ?? 0) + 1;
          } else {
            ageGroups['65+'] = (ageGroups['65+'] ?? 0) + 1;
          }
        }

        int newPatients = 0;
        int returningPatients = 0;
        final List<Map<String, dynamic>> inactiveList = [];

        for (var p in targetPatients) {
          final count = patientApptCounts[p.id] ?? 1;
          if (count > 1) {
            returningPatients++;
          } else {
            newPatients++;
          }

          final lastVisit = patientLastVisits[p.id];
          if (lastVisit != null) {
            final days = now.difference(lastVisit).inDays;
            if (days >= 60) {
              inactiveList.add({
                'name': p.name,
                'last_visit':
                    '${lastVisit.year}-${lastVisit.month.toString().padLeft(2, '0')}-${lastVisit.day.toString().padLeft(2, '0')}',
                'days': days,
              });
            }
          }
        }

        final Map<String, dynamic> invEq = {};
        if (clinicId != null && clinicId.isNotEmpty) invEq['clinic_id'] = clinicId;
        final invoicesRaw = await _cloudService.select(
          table: SupabaseTables.invoices,
          eq: invEq.isNotEmpty ? invEq : null,
          gte: {'created_at': dateHelper.rangeStartUtcIso},
          lte: {'created_at': dateHelper.rangeEndUtcIso},
        );
        final allInvoices =
            invoicesRaw.map((raw) => InvoiceModel.fromJson(raw)).toList();

        final targetApptIds = appts.map((a) => a.id).toSet();

        final totalRevenue = allInvoices
            .where((inv) => targetApptIds.contains(inv.sourceId))
            .fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);

        final totalApptVisits = patientApptCounts.values.fold<int>(0, (sum, c) => sum + c);

        final total = targetPatients.length;
        final returnRate = total > 0 ? (returningPatients / total * 100) : 0.0;
        final avgVisitsPerPatient = total > 0 ? (totalApptVisits / total) : 0.0;
        final avgRevenuePerPatient = total > 0 ? (totalRevenue / total) : 0.0;
        final newPatientsPercentage = total > 0 ? (newPatients / total * 100) : 0.0;
        final returningPatientsPercentage = total > 0 ? (returningPatients / total * 100) : 0.0;

        final result = PatientStatsModel.fromMap({
          'total': total,
          'new': newPatients,
          'returning': returningPatients,
          'return_rate': returnRate,
          'avg_visits_per_patient': avgVisitsPerPatient,
          'avg_revenue_per_patient': avgRevenuePerPatient,
          'new_patients_percentage': newPatientsPercentage,
          'returning_patients_percentage': returningPatientsPercentage,
          'by_gender': {'male': males, 'female': females},
          'by_age': ageGroups,
          'inactive': inactiveList,
        });
        _cacheManager.set(cacheKey, result);
        return result;
      }
    } catch (_) {}

    return PatientStatsModel.empty();
  }

  // ────────────────────────────────────────────────────────
  // fetchDoctorPerformance
  // ────────────────────────────────────────────────────────
  @override
  Future<List<DoctorPerformanceModel>> fetchDoctorPerformance({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'doc_perf_${clinicId ?? ''}_${range.name}_${customDateRange?.start.millisecondsSinceEpoch}_${customDateRange?.end.millisecondsSinceEpoch}';
    if (forceRefresh) {
      _cacheManager.clear(cacheKey);
    } else {
      final cached = _cacheManager.get<List<DoctorPerformanceModel>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final dateHelper = DateRangeHelper.fromRange(
        range: range,
        customDateRange: customDateRange,
      );

      final Map<String, dynamic> staffEq = {"role": StaffRoles.doctor.name};
      if (clinicId != null && clinicId.isNotEmpty) {
        staffEq["clinic_id"] = clinicId;
      }

      final staffDocs = await _cloudService.select(
        table: SupabaseTables.clinicStaff,
        eq: staffEq,
      );

      final Set<String> uniqueDoctorIds = staffDocs
          .map((staff) => staff["user_id"] as String? ?? "")
          .where((id) => id.isNotEmpty)
          .toSet();

      final List<DoctorPerformanceModel> performanceList = [];

      for (var docUserId in uniqueDoctorIds) {

        final userDocs = await _cloudService.select(
          table: SupabaseTables.users,
          eq: {"id": docUserId},
        );
        final userDoc = userDocs.isNotEmpty ? userDocs.first : null;

        final docName =
            userDoc?["full_name"] as String? ?? userDoc?["name"] as String? ?? "طبيب غير معروف";
        final avatarUrl = userDoc?["avatar_url"] as String?;

        final Map<String, dynamic> apptEq = {"doctor_id": docUserId};
        if (clinicId != null && clinicId.isNotEmpty) {
          apptEq["clinic_id"] = clinicId;
        }

        final apptsRaw = await _cloudService.select(
          table: SupabaseTables.appointments,
          eq: apptEq,
          gte: {'created_at': dateHelper.rangeStartUtcIso},
          lte: {'created_at': dateHelper.rangeEndUtcIso},
        );

        final appts =
            apptsRaw.map((raw) => AppointmentModel.fromJson(raw)).toList();

        final validAppts = appts.where((a) {
          if (a.status == AppointmentStatus.cancelled) return false;
          final apptDt = DateTime.tryParse(a.date) ?? a.createdAt;
          return dateHelper.inRange(apptDt);
        }).toList();

        double docRevenue = 0;
        for (var appt in validAppts) {
          final invDocs = await _cloudService.select(
            table: SupabaseTables.invoices,
            eq: {"source_id": appt.id},
          );

          if (invDocs.isNotEmpty) {
            final inv = InvoiceModel.fromJson(invDocs.first);
            docRevenue += inv.paidAmount;
          } else {
            docRevenue += (appt.invoiceAmount as num?)?.toDouble() ??
                (appt.price as num).toDouble();
          }
        }

        performanceList.add(
          DoctorPerformanceModel(
            doctorId: docUserId,
            doctorName: docName,
            visitCount: validAppts.length,
            revenue: docRevenue,
            rating: 5,
            trend: 'up',
            avatarUrl: avatarUrl,
          ),
        );
      }

      performanceList.sort((a, b) => b.revenue.compareTo(a.revenue));

      final totalClinicRevenue =
          performanceList.fold<double>(0.0, (sum, d) => sum + d.revenue);

      final updatedList = performanceList.map((d) {
        final sharePercentage = totalClinicRevenue > 0
            ? ((d.revenue / totalClinicRevenue) * 100).round()
            : 0;

        return DoctorPerformanceModel(
          doctorId: d.doctorId,
          doctorName: d.doctorName,
          visitCount: d.visitCount,
          revenue: d.revenue,
          rating: sharePercentage,
          trend: d.revenue > 0 ? 'up' : 'stable',
          avatarUrl: d.avatarUrl,
        );
      }).toList();

      _cacheManager.set(cacheKey, updatedList);
      return updatedList;
    } catch (_) {}

    return const [];
  }

  // ────────────────────────────────────────────────────────
  // fetchDrugStats
  // ────────────────────────────────────────────────────────
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

    try {
      final Map<String, dynamic> pEq = {};
      if (doctorId != null && doctorId.isNotEmpty) pEq['doctor_id'] = doctorId;
      if (clinicId != null && clinicId.isNotEmpty) pEq['clinic_id'] = clinicId;

      final prescriptions = await _cloudService.select(
        table: SupabaseTables.prescriptions,
        columns: _prescriptionColumns,
        eq: pEq.isNotEmpty ? pEq : null,
      );

      if (prescriptions.isEmpty) {
        return const DrugStatsEntity(byCategory: [], topDrugs: []);
      }

      final pIds = prescriptions.map((p) => p['id'] as String).toSet();

      // ── جلب عناصر الروشتات والأدوية بأعمدة محددة فقط ──
      final itemsRaw = await _cloudService.select(
        table: SupabaseTables.prescriptionItems,
        columns: _prescriptionItemColumns,
      );
      final drugsRaw = await _cloudService.select(
        table: SupabaseTables.drugs,
        columns: _drugColumns,
      );
      final templatesRaw = doctorId != null && doctorId.isNotEmpty
          ? await _cloudService.select(table: SupabaseTables.prescriptionTemplates, eq: {'doctor_id': doctorId})
          : await _cloudService.select(table: SupabaseTables.prescriptionTemplates);

      final Map<String, Map<String, dynamic>> drugsMap = {
        for (var d in drugsRaw) (d['id'] as String): d
      };

      final filteredItems = itemsRaw.where((item) => pIds.contains(item['prescription_id'] as String)).toList();

      final totalPrescriptions = prescriptions.length;
      final totalItemsCount = filteredItems.length;
      final double avgDrugsPerRx = totalPrescriptions > 0 ? (totalItemsCount / totalPrescriptions) : 0.0;

      final prnItemsCount = filteredItems.where((item) => item['is_prn'] == true).length;
      final double prnPercentage = totalItemsCount > 0 ? (prnItemsCount / totalItemsCount * 100) : 0.0;

      // ── Top Diagnoses & Top Diagnosis Name ──
      final Map<String, int> diagnosisCounts = {};
      for (var p in prescriptions) {
        final diag = (p['diagnosis'] as String?)?.trim();
        if (diag != null && diag.isNotEmpty) {
          diagnosisCounts[diag] = (diagnosisCounts[diag] ?? 0) + 1;
        }
      }
      final sortedDiagnoses = diagnosisCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topDiagnosisName = sortedDiagnoses.isNotEmpty ? sortedDiagnoses.first.key : '';
      final topDiagnoses = sortedDiagnoses.map((e) => NameCountStatEntity(
        name: e.key,
        count: e.value,
        percentage: totalPrescriptions > 0 ? (e.value / totalPrescriptions * 100) : 0.0,
      )).toList();

      // ── Top Drugs & Categories & Chronic Drugs ──
      final Map<String, int> drugCounts = {};
      final Map<String, int> categoryCounts = {};
      final Map<String, int> chronicCounts = {};
      final Map<String, Set<String>> drugPatientsMap = {};

      final Map<String, String> pPatientMap = {
        for (var p in prescriptions) (p['id'] as String): (p['patient_id'] as String? ?? '')
      };

      for (var item in filteredItems) {
        final drugId = item['drug_id'] as String?;
        if (drugId == null) continue;
        final drugData = drugsMap[drugId];
        final tradeName = drugData?['trade_name'] as String? ?? 'دواء غير محدد';
        final category = drugData?['category'] as String? ?? 'عام';

        drugCounts[tradeName] = (drugCounts[tradeName] ?? 0) + 1;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

        if (item['duration'] == 0) {
          chronicCounts[tradeName] = (chronicCounts[tradeName] ?? 0) + 1;
        }

        final rxId = item['prescription_id'] as String;
        final patientId = pPatientMap[rxId] ?? '';
        if (patientId.isNotEmpty) {
          drugPatientsMap.putIfAbsent(tradeName, () => {}).add(patientId);
        }
      }

      final sortedDrugs = drugCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topDrugs = sortedDrugs.map((e) {
        final drugId = drugsMap.entries.firstWhere(
          (d) => (d.value['trade_name'] as String?) == e.key,
          orElse: () => const MapEntry('', {}),
        ).key;
        final generic = drugsMap[drugId]?['generic_name'] as String?;
        return TopDrugStatEntity(
          name: e.key,
          genericName: generic,
          count: e.value,
          percentage: totalItemsCount > 0 ? (e.value / totalItemsCount * 100) : 0.0,
        );
      }).toList();

      final sortedCategories = categoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final byCategory = sortedCategories.map((e) => DrugCategoryStatEntity(
        category: e.key,
        count: e.value,
        percentage: totalItemsCount > 0 ? (e.value / totalItemsCount * 100) : 0.0,
      )).toList();

      final chronicDrugs = chronicCounts.entries.map((e) => TopDrugStatEntity(
        name: e.key,
        count: e.value,
        percentage: totalItemsCount > 0 ? (e.value / totalItemsCount * 100) : 0.0,
      )).toList();

      // ── Template Stats ──
      final totalTemplateUses = templatesRaw.fold<int>(0, (sum, t) => sum + ((t['user_count'] ?? 0) as num).toInt());
      final templateStats = templatesRaw.map((t) {
        final uCount = ((t['user_count'] ?? 0) as num).toInt();
        return TemplateStatsEntity(
          id: t['id'] as String,
          name: t['name'] as String? ?? 'قالب',
          userCount: uCount,
          percentage: totalTemplateUses > 0 ? (uCount / totalTemplateUses * 100) : 0.0,
        );
      }).toList()..sort((a, b) => b.userCount.compareTo(a.userCount));

      // ── Monthly Prescription Trend (Last 6 Months) ──
      final now = DateTime.now();
      final List<MonthlyPrescriptionTrendEntity> monthlyTrend = [];
      for (int i = 5; i >= 0; i--) {
        final mDate = DateTime(now.year, now.month - i, 1);
        final monthStr = '${mDate.year}-${mDate.month.toString().padLeft(2, '0')}';
        final mRxList = prescriptions.where((p) {
          final cAt = p['created_at'] as String?;
          return cAt != null && cAt.startsWith(monthStr);
        }).toList();

        final mRxIds = mRxList.map((p) => p['id'] as String).toSet();
        final mItems = filteredItems.where((item) => mRxIds.contains(item['prescription_id'] as String)).length;
        final double avgD = mRxList.isNotEmpty ? (mItems / mRxList.length) : 0.0;

        monthlyTrend.add(MonthlyPrescriptionTrendEntity(
          month: monthStr,
          count: mRxList.length,
          avgDrugs: avgD,
        ));
      }

      // ── Dosing Patterns ──
      final Map<String, int> patternCounts = {};
      for (var item in filteredItems) {
        if (item['is_prn'] == true) {
          patternCounts['عند اللزوم (PRN)'] = (patternCounts['عند اللزوم (PRN)'] ?? 0) + 1;
        } else {
          final freq = item['frequency'] ?? 1;
          final dur = item['duration'] ?? 7;
          final key = '$freq مرات daily - $dur أيام';
          patternCounts[key] = (patternCounts[key] ?? 0) + 1;
        }
      }
      final commonDosages = patternCounts.entries.map((e) => DosingPatternStatEntity(
        pattern: e.key,
        count: e.value,
        percentage: totalItemsCount > 0 ? (e.value / totalItemsCount * 100) : 0.0,
      )).toList()..sort((a, b) => b.count.compareTo(a.count));

      // ── Drug - Diagnosis Links ──
      final Map<String, int> drugDiagMap = {};
      final Map<String, String> rxDiagMap = {
        for (var p in prescriptions) (p['id'] as String): (p['diagnosis'] as String? ?? 'تشخيص عام')
      };
      for (var item in filteredItems) {
        final rxId = item['prescription_id'] as String;
        final diag = rxDiagMap[rxId] ?? 'عام';
        final drugId = item['drug_id'] as String?;
        final tradeName = drugsMap[drugId]?['trade_name'] as String? ?? 'دواء';
        final key = '$diag|$tradeName';
        drugDiagMap[key] = (drugDiagMap[key] ?? 0) + 1;
      }
      final drugDiagnosisLinks = drugDiagMap.entries.map((e) {
        final parts = e.key.split('|');
        return DrugDiagnosisStatEntity(
          diagnosis: parts[0],
          drugName: parts[1],
          count: e.value,
        );
      }).toList()..sort((a, b) => b.count.compareTo(a.count));

      // ── Repeated Drugs per Patient ──
      final Map<String, Map<String, int>> patientDrugCounts = {};
      for (var item in filteredItems) {
        final rxId = item['prescription_id'] as String;
        final patientId = pPatientMap[rxId] ?? '';
        final drugId = item['drug_id'] as String?;
        final tradeName = drugsMap[drugId]?['trade_name'] as String? ?? 'دواء';
        if (patientId.isNotEmpty) {
          patientDrugCounts.putIfAbsent(tradeName, () => {});
          patientDrugCounts[tradeName]![patientId] = (patientDrugCounts[tradeName]![patientId] ?? 0) + 1;
        }
      }
      final repeatedDrugs = patientDrugCounts.entries.map((e) {
        final totalRepeat = e.value.values.fold<int>(0, (sum, c) => sum + c);
        final patientCount = e.value.keys.length;
        return RepeatDrugStatEntity(
          drugName: e.key,
          repeatCount: totalRepeat,
          patientCount: patientCount,
        );
      }).toList()..sort((a, b) => b.repeatCount.compareTo(a.repeatCount));

      // ── Switched Drugs ──
      final List<SwitchedDrugStatEntity> switchedDrugs = [];

      // ── Patient Reach ──
      final patientReach = drugPatientsMap.entries.map((e) {
        return PatientReachStatEntity(
          drugName: e.key,
          uniquePatients: e.value.length,
          totalPrescribedCount: drugCounts[e.key] ?? 0,
        );
      }).toList()..sort((a, b) => b.uniquePatients.compareTo(a.uniquePatients));

      final result = DrugStatsEntity(
        totalPrescriptions: totalPrescriptions,
        avgDrugsPerPrescription: avgDrugsPerRx,
        prnPercentage: prnPercentage,
        topDiagnosisName: topDiagnosisName,
        byCategory: byCategory,
        topDrugs: topDrugs,
        topDiagnoses: topDiagnoses,
        templateStats: templateStats,
        monthlyTrend: monthlyTrend,
        commonDosages: commonDosages,
        chronicDrugs: chronicDrugs,
        drugDiagnosisLinks: drugDiagnosisLinks,
        repeatedDrugs: repeatedDrugs,
        switchedDrugs: switchedDrugs,
        patientReach: patientReach,
      );
      _cacheManager.set(cacheKey, result);
      return result;
    } catch (_) {}

    return const DrugStatsEntity(byCategory: [], topDrugs: []);
  }

  // ────────────────────────────────────────────────────────
  // fetchTemplateStats
  // ────────────────────────────────────────────────────────
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

    try {
      final rawTemplates = doctorId != null && doctorId.isNotEmpty
          ? await _cloudService.select(
              table: SupabaseTables.prescriptionTemplates,
              eq: {'doctor_id': doctorId},
              order: 'user_count',
              ascending: false,
            )
          : await _cloudService.select(
              table: SupabaseTables.prescriptionTemplates,
              order: 'user_count',
              ascending: false,
            );

      if (rawTemplates.isNotEmpty) {
        final result = TemplateStatsModel.fromRawList(rawTemplates);
        _cacheManager.set(cacheKey, result);
        return result;
      }
    } catch (_) {}

    return const [];
  }

  // ────────────────────────────────────────────────────────
  // fetchClinicReport — تم إصلاح مشكلة N+1 Queries
  // الآن يجلب كل البيانات دفعة واحدة ثم يوزعها بالـ Map
  // ────────────────────────────────────────────────────────
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
    final clinicsRaw = await _cloudService.select(
      table: SupabaseTables.clinics,
      eq: {'owner_id': ownerId},
    );
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);

    // ── جلب كل البيانات دفعة واحدة بدلاً من N+1 queries ──
    final clinicIds = clinicsRaw.map((c) => c['id'] as String).toList();

    if (clinicIds.isEmpty) {
      return const ClinicReportEntity(
        totalActiveClinics: 0,
        totalExpectedRevenue: 0,
        totalCollectedAmount: 0,
        totalExpenses: 0,
        totalNetProfit: 0,
        totalAppointmentsToday: 0,
        totalDoctors: 0,
        clinics: [],
      );
    }

    // جلب كل البيانات دفعة واحدة (بدلاً من 4 queries لكل عيادة)
    final allStaff = await _cloudService.select(
      table: SupabaseTables.clinicStaff,
      eq: {'role': StaffRoles.doctor.name},
    );
    final allAppts = await _cloudService.select(
      table: SupabaseTables.appointments,
      columns: _apptColumns,
    );
    final allInvoices = await _cloudService.select(
      table: SupabaseTables.invoices,
      columns: _invoiceColumns,
    );
    final allExpenses = await _cloudService.select(
      table: SupabaseTables.expenses,
      columns: _expenseColumns,
    );

    // ── تجميع البيانات حسب العيادة في Maps ──
    final staffByClinic = <String, List<Map<String, dynamic>>>{};
    for (var s in allStaff) {
      final cId = s['clinic_id'] as String? ?? '';
      staffByClinic.putIfAbsent(cId, () => []).add(s);
    }

    final apptsByClinic = <String, List<Map<String, dynamic>>>{};
    for (var a in allAppts) {
      final cId = a['clinic_id'] as String? ?? '';
      apptsByClinic.putIfAbsent(cId, () => []).add(a);
    }

    final invoicesByClinic = <String, List<Map<String, dynamic>>>{};
    for (var inv in allInvoices) {
      final cId = inv['clinic_id'] as String? ?? '';
      invoicesByClinic.putIfAbsent(cId, () => []).add(inv);
    }

    final expensesByClinic = <String, List<Map<String, dynamic>>>{};
    for (var exp in allExpenses) {
      final cId = exp['clinic_id'] as String? ?? '';
      expensesByClinic.putIfAbsent(cId, () => []).add(exp);
    }

    List<ClinicComparisonItem> comparisonItems = [];
    int totalActive = 0;
    double totalExpRev = 0;
    double totalColAmt = 0;
    double totalExp = 0;
    double totalNet = 0;
    int totalApptsToday = 0;
    int totalDocs = 0;

    for (final clinicMap in clinicsRaw) {
      final clinicId = clinicMap['id'] as String;
      final clinicName = clinicMap['name'] as String? ?? 'عيادة بدون اسم';
      final isActive = clinicMap['is_active'] as bool? ?? true;

      if (isActive) totalActive++;

      // 1. Doctors — من الـ Map بدلاً من query جديد
      final staffList = staffByClinic[clinicId] ?? [];
      final numberOfDoctors = staffList.length;
      totalDocs += numberOfDoctors;

      // 2. Appointments — من الـ Map بدلاً من query جديد
      final apptsList = apptsByClinic[clinicId] ?? [];
      final dayAppointments = apptsList.where((a) => a['date'] == todayStr).length;
      totalApptsToday += dayAppointments;

      final finishedAppointments = apptsList.where((a) {
        final dateStr = a['date'] as String?;
        if (dateStr == null || dateStr.length < 7) return false;
        final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
        final month = int.tryParse(dateStr.substring(5, 7)) ?? 0;
        return year == now.year && month == now.month && a['status'] == 'done';
      }).length;

      // الإيراد المتوقع للشهر الحالي = مجموع أسعار المواعيد لهذا الشهر
      final monthAppts = apptsList.where((a) {
        final dateStr = a['date'] as String?;
        if (dateStr == null || dateStr.length < 7) return false;
        final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
        final month = int.tryParse(dateStr.substring(5, 7)) ?? 0;
        return year == now.year && month == now.month;
      });
      final expectedRevenue = monthAppts.fold<double>(
        0.0,
        (sum, a) => sum + ((a['price'] ?? 0.0) as num).toDouble(),
      );

      // 3. Invoices & Expenses — من الـ Map بدلاً من query جديد
      final invoicesList = invoicesByClinic[clinicId] ?? [];
      final expensesList = expensesByClinic[clinicId] ?? [];

      List<PerformanceStatistics> performance = [];
      List<PerformanceStatistics> expectedPerformance = [];
      for (int i = 0; i < 5; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthInvoices = invoicesList.where((inv) {
          final createdAtStr = inv['created_at'] as String?;
          if (createdAtStr == null) return false;
          final createdAt = DateTime.tryParse(createdAtStr);
          if (createdAt == null) return false;
          return createdAt.year == monthDate.year && createdAt.month == monthDate.month;
        });

        final rev = monthInvoices.fold<double>(
          0.0,
          (sum, inv) => sum + ((inv['paid_amount'] ?? 0.0) as num).toDouble(),
        );
        performance.add(PerformanceStatistics(month: monthDate, amount: rev));

        final monthApptsHistorical = apptsList.where((a) {
          final dateStr = a['date'] as String?;
          if (dateStr == null || dateStr.length < 7) return false;
          final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
          final month = int.tryParse(dateStr.substring(5, 7)) ?? 0;
          return year == monthDate.year && month == monthDate.month;
        });
        final expRev = monthApptsHistorical.fold<double>(
          0.0,
          (sum, a) => sum + ((a['price'] ?? 0.0) as num).toDouble(),
        );
        expectedPerformance.add(PerformanceStatistics(month: monthDate, amount: expRev));
      }

      // المحصل الفعلي للشهر الحالي من جدول الفواتير
      final collectedAmount = performance.first.amount;

      final monthlyExpenses = expensesList.where((exp) {
        final dateStr = exp['date'] as String?;
        if (dateStr == null || dateStr.length < 7) return false;
        final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
        final month = int.tryParse(dateStr.substring(5, 7)) ?? 0;
        return year == now.year && month == now.month;
      }).fold<double>(
        0.0,
        (sum, exp) => sum + ((exp['amount'] ?? 0.0) as num).toDouble(),
      );

      final netProfit = collectedAmount - monthlyExpenses;
      final baseRevForMargin = collectedAmount > 0 ? collectedAmount : expectedRevenue;
      final profitMargin = baseRevForMargin > 0 ? (netProfit / baseRevForMargin * 100) : 0.0;
      final revPerDoc = numberOfDoctors > 0 ? (collectedAmount / numberOfDoctors) : collectedAmount;

      totalExpRev += expectedRevenue;
      totalColAmt += collectedAmount;
      totalExp += monthlyExpenses;
      totalNet += netProfit;

      comparisonItems.add(ClinicComparisonItem(
        clinicId: clinicId,
        clinicName: clinicName,
        expectedRevenue: expectedRevenue,
        collectedAmount: collectedAmount,
        monthlyExpenses: monthlyExpenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        dayAppointments: dayAppointments,
        finishedAppointments: finishedAppointments,
        numberOfDoctors: numberOfDoctors,
        revenuePerDoctor: revPerDoc,
        monthlyPerformance: performance,
        monthlyExpectedPerformance: expectedPerformance,
      ));
    }

    comparisonItems.sort((a, b) => b.collectedAmount.compareTo(a.collectedAmount));

    final result = ClinicReportEntity(
      totalActiveClinics: totalActive,
      totalExpectedRevenue: totalExpRev,
      totalCollectedAmount: totalColAmt,
      totalExpenses: totalExp,
      totalNetProfit: totalNet,
      totalAppointmentsToday: totalApptsToday,
      totalDoctors: totalDocs,
      clinics: comparisonItems,
    );
    _cacheManager.set(cacheKey, result);
    return result;
  }
}
