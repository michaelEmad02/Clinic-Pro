class PerformanceStatistics {
  final DateTime month;
  final double amount;

  PerformanceStatistics({required this.month, required this.amount});

  factory PerformanceStatistics.fromJson(Map<String, dynamic> data) {
    return PerformanceStatistics(month: data["month"], amount: data["amount"]);
  }
}
