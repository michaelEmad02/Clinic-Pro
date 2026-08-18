// ─────────────────────────────────────────
// حالات Cubit إيراد الأسبوع للمخطط البياني
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class OwnerWeeklyRevenueState extends Equatable {
  const OwnerWeeklyRevenueState();

  @override
  List<Object?> get props => [];
}

class OwnerWeeklyRevenueInitial extends OwnerWeeklyRevenueState {}

class OwnerWeeklyRevenueLoading extends OwnerWeeklyRevenueState {}

class OwnerWeeklyRevenueLoaded extends OwnerWeeklyRevenueState {
  final List<double> weeklyRevenue;

  const OwnerWeeklyRevenueLoaded(this.weeklyRevenue);

  @override
  List<Object?> get props => [weeklyRevenue];
}

class OwnerWeeklyRevenueError extends OwnerWeeklyRevenueState {
  final String message;

  const OwnerWeeklyRevenueError(this.message);

  @override
  List<Object?> get props => [message];
}
