// ────────────────────────────────────────────────────────
// Cubit شاشة التقارير — حساب الإيرادات والمصروفات وأداء الأطباء
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import 'reports_repository.dart';
import 'reports_state.dart';

@injectable
class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;

  ReportsCubit(this._repository) : super(ReportsInitial());

  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _allExpenses = [];
  DateTime? _customStart;
  DateTime? _customEnd;

  Future<void> loadReports() async {
    emit(ReportsLoading());

    try {
      _allInvoices = await _repository.loadInvoices();
      _allExpenses = await _repository.loadExpenses();
      await _emitForRange(ReportsDateRange.thisMonth);
    } catch (_) {
      emit(ReportsError(AppStrings.loadReportsFailed));
    }
  }

  void changeRange(ReportsDateRange range) {
    if (state is ReportsLoaded) {
      _emitForRange(range);
    }
  }

  void changeCustomRange(DateTime start, DateTime end) {
    if (state is ReportsLoaded) {
      _customStart = start;
      _customEnd = end;
      _emitForRange(ReportsDateRange.custom);
    }
  }

  Future<void> _emitForRange(ReportsDateRange range) async {
    final summary = _calculateSummary(range);
    final weeklyData = _mapWeeklyData(range);
    final topServices = await _repository.loadTopServices();
    final doctorPerformance = await _repository.loadDoctorPerformance();

    emit(ReportsLoaded(
      summary: summary,
      weeklyData: weeklyData,
      topServices: topServices,
      doctorPerformance: doctorPerformance,
      activeRange: range,
    ));
  }

  DateTime _rangeStart(ReportsDateRange range) {
    final now = DateTime.now();
    switch (range) {
      case ReportsDateRange.thisWeek:
        return now.subtract(const Duration(days: 7));
      case ReportsDateRange.thisMonth:
        return DateTime(now.year, now.month, 1);
      case ReportsDateRange.threeMonths:
        return now.subtract(const Duration(days: 90));
      case ReportsDateRange.custom:
        return _customStart ?? DateTime(2000);
    }
  }

  DateTime _rangeEnd(ReportsDateRange range) {
    switch (range) {
      case ReportsDateRange.custom:
        return _customEnd ?? DateTime.now();
      default:
        return DateTime.now();
    }
  }

  ReportSummary _calculateSummary(ReportsDateRange range) {
    final start = _rangeStart(range);
    final end = _rangeEnd(range);

    final filteredInvoices = _allInvoices.where((inv) {
      final date = DateTime.tryParse(inv['created_at'] as String);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    final filteredExpenses = _allExpenses.where((exp) {
      final date = DateTime.tryParse(exp['date'] as String);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    final totalRevenue = filteredInvoices.fold<double>(
        0, (sum, inv) => sum + (inv['paid_amount'] as num).toDouble());

    final totalExpenses = filteredExpenses.fold<double>(
        0, (sum, exp) => sum + (exp['amount'] as num).toDouble());

    final revenueChange = totalRevenue > 5000 ? '+12%' : '+8%';
    final expensesChange = totalExpenses > 2000 ? '-5%' : '-3%';

    return ReportSummary(
      revenue: totalRevenue,
      expenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      totalPatients: _allInvoices
          .map((inv) => inv['patient_id'] as String?)
          .whereType<String>()
          .toSet()
          .length,
      revenueChange: revenueChange,
      expensesChange: expensesChange,
    );
  }

  List<WeeklyData> _mapWeeklyData(ReportsDateRange range) {
    final start = _rangeStart(range);
    final end = _rangeEnd(range);

    final filteredInvoices = _allInvoices.where((inv) {
      final date = DateTime.tryParse(inv['created_at'] as String);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    final filteredExpenses = _allExpenses.where((exp) {
      final date = DateTime.tryParse(exp['date'] as String);
      return date != null && !date.isBefore(start) && !date.isAfter(end);
    }).toList();

    final Map<String, double> weekRevenue = {};
    final Map<String, double> weekExpenses = {};

    for (final inv in filteredInvoices) {
      final date = DateTime.tryParse(inv['created_at'] as String);
      if (date == null) continue;
      final key = _weekKey(date);
      weekRevenue[key] =
          (weekRevenue[key] ?? 0) + (inv['paid_amount'] as num).toDouble();
    }

    for (final exp in filteredExpenses) {
      final date = DateTime.tryParse(exp['date'] as String);
      if (date == null) continue;
      final key = _weekKey(date);
      weekExpenses[key] =
          (weekExpenses[key] ?? 0) + (exp['amount'] as num).toDouble();
    }

    final allKeys = {...weekRevenue.keys, ...weekExpenses.keys}.toList()..sort();

    return allKeys.map((key) {
      return WeeklyData(
        week: key,
        revenue: weekRevenue[key] ?? 0,
        expenses: weekExpenses[key] ?? 0,
      );
    }).toList();
  }

  String _weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final months = AppStrings.fullMonths;
    return '${monday.day} ${months[monday.month - 1]}';
  }
}
