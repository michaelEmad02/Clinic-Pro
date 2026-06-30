// ────────────────────────────────────────────────────────
// Cubit شاشة التقارير — حساب الإيرادات والمصروفات وأداء الأطباء
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(ReportsInitial());

  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _allExpenses = [];

  Future<void> loadReports() async {
    emit(ReportsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _allInvoices = MockData.invoices;
      _allExpenses = MockData.expenses;
      _emitForRange(ReportsDateRange.thisMonth);
    } catch (_) {
      emit(const ReportsError('تعذّر تحميل التقارير'));
    }
  }

  void changeRange(ReportsDateRange range) {
    if (state is ReportsLoaded) {
      _emitForRange(range);
    }
  }

  void _emitForRange(ReportsDateRange range) {
    final summary = _calculateSummary(range);
    final weeklyData = _mapWeeklyData(range);
    final topServices = _mapTopServices();
    final doctorPerformance = _mapDoctorPerformance();

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
        return DateTime(2000);
    }
  }

  ReportSummary _calculateSummary(ReportsDateRange range) {
    final start = _rangeStart(range);

    final filteredInvoices = _allInvoices.where((inv) {
      final date = DateTime.tryParse(inv['created_at'] as String);
      return date != null && !date.isBefore(start);
    }).toList();

    final filteredExpenses = _allExpenses.where((exp) {
      final date = DateTime.tryParse(exp['date'] as String);
      return date != null && !date.isBefore(start);
    }).toList();

    final totalRevenue = filteredInvoices.fold<double>(
        0, (sum, inv) => sum + (inv['paid_amount'] as num).toDouble());

    final totalExpenses = filteredExpenses.fold<double>(
        0, (sum, exp) => sum + (exp['amount'] as num).toDouble());

    return ReportSummary(
      revenue: totalRevenue,
      expenses: totalExpenses,
      netProfit: totalRevenue - totalExpenses,
      totalPatients: MockData.patients.length,
      revenueChange: totalRevenue > 5000 ? '+12%' : '+8%',
      expensesChange: totalExpenses > 2000 ? '-5%' : '-3%',
    );
  }

  List<WeeklyData> _mapWeeklyData(ReportsDateRange range) {
    final start = _rangeStart(range);

    final filteredInvoices = _allInvoices.where((inv) {
      final date = DateTime.tryParse(inv['created_at'] as String);
      return date != null && !date.isBefore(start);
    }).toList();

    final filteredExpenses = _allExpenses.where((exp) {
      final date = DateTime.tryParse(exp['date'] as String);
      return date != null && !date.isBefore(start);
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
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${monday.day} ${months[monday.month - 1]}';
  }

  List<TopServiceItem> _mapTopServices() {
    return MockData.topServices.map((s) {
      return TopServiceItem(
        name: s['name'] as String,
        revenue: (s['revenue'] as num).toDouble(),
        icon: s['icon'] as String,
      );
    }).toList();
  }

  List<DoctorPerformanceItem> _mapDoctorPerformance() {
    return MockData.doctorPerformance.map((d) {
      return DoctorPerformanceItem(
        doctorId: d['doctor_id'] as String,
        doctorName: d['doctor_name'] as String,
        patientCount: d['patient_count'] as int,
        revenue: (d['revenue'] as num).toDouble(),
        rating: d['rating'] as int,
        trend: d['trend'] as String,
        avatarUrl: d['avatar_url'] as String?,
      );
    }).toList();
  }
}
