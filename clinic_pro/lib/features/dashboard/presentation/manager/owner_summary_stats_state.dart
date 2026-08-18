// ─────────────────────────────────────────
// حالات Cubit إحصائيات ملخص لوحة المالك
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/owner_summary_stats_entity.dart';

abstract class OwnerSummaryStatsState extends Equatable {
  const OwnerSummaryStatsState();

  @override
  List<Object?> get props => [];
}

class OwnerSummaryStatsInitial extends OwnerSummaryStatsState {}

class OwnerSummaryStatsLoading extends OwnerSummaryStatsState {}

class OwnerSummaryStatsLoaded extends OwnerSummaryStatsState {
  final OwnerSummaryStatsEntity stats;

  const OwnerSummaryStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class OwnerSummaryStatsError extends OwnerSummaryStatsState {
  final String message;

  const OwnerSummaryStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
