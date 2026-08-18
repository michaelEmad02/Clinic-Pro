import '../../domain/entities/reports_entities.dart';

class WeeklyRevenueModel extends WeeklyRevenueEntity {
  const WeeklyRevenueModel({
    required super.week,
    required super.revenue,
    required super.collected,
    required super.expenses,
  });

  factory WeeklyRevenueModel.fromMap(Map<String, dynamic> map) {
    return WeeklyRevenueModel(
      week: map['week'] as String,
      revenue: (map['revenue'] as num).toDouble(),
      collected: (map['collected'] as num? ?? 0.0).toDouble(),
      expenses: (map['expenses'] as num? ?? 0.0).toDouble(),
    );
  }
}

class ExpenseCategoryStatModel extends ExpenseCategoryStatEntity {
  const ExpenseCategoryStatModel({
    required super.category,
    required super.amount,
    required super.percentage,
  });

  factory ExpenseCategoryStatModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryStatModel(
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      percentage: (map['percentage'] as num? ?? 0.0).toDouble(),
    );
  }
}

class RevenueSummaryModel extends RevenueSummaryEntity {
  const RevenueSummaryModel({
    required super.totalRevenue,
    required super.collectedAmount,
    required super.totalExpenses,
    required super.netProfit,
    required super.pendingAmount,
    required super.revenueChange,
    required super.expensesChange,
    required super.chart,
    super.expensesBreakdown = const [],
  });

  factory RevenueSummaryModel.fromMap(Map<String, dynamic> map) {
    final chartList = ((map['chart'] ?? []) as List)
        .map((item) => WeeklyRevenueModel.fromMap(item as Map<String, dynamic>))
        .toList();
    final expensesList = ((map['expenses_breakdown'] ?? []) as List)
        .map((item) => ExpenseCategoryStatModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return RevenueSummaryModel(
      totalRevenue: ((map['total_revenue'] ?? 0.0) as num).toDouble(),
      collectedAmount: ((map['collected_amount'] ?? 0.0) as num).toDouble(),
      totalExpenses: ((map['total_expenses'] ?? 0.0) as num).toDouble(),
      netProfit: ((map['net_profit'] ?? 0.0) as num).toDouble(),
      pendingAmount: ((map['pending_amount'] ?? 0.0) as num).toDouble(),
      revenueChange: (map['revenue_change'] ?? '0%').toString(),
      expensesChange: (map['expenses_change'] ?? '0%').toString(),
      chart: chartList,
      expensesBreakdown: expensesList,
    );
  }

  factory RevenueSummaryModel.empty() {
    return const RevenueSummaryModel(
      totalRevenue: 0.0,
      collectedAmount: 0.0,
      totalExpenses: 0.0,
      netProfit: 0.0,
      pendingAmount: 0.0,
      revenueChange: '0%',
      expensesChange: '0%',
      chart: [],
      expensesBreakdown: [],
    );
  }
}
