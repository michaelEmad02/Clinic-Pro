// ─────────────────────────────────────────
// Cubit إحصائيات ملخص لوحة المالك (Summary Cards Cubit)
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/usecases/get_owner_summary_stats_usecase.dart';
import 'owner_summary_stats_state.dart';

@injectable
class OwnerSummaryStatsCubit extends Cubit<OwnerSummaryStatsState> {
  final GetOwnerSummaryStatsUseCase _useCase;

  OwnerSummaryStatsCubit(this._useCase) : super(OwnerSummaryStatsInitial());

  void loadSummaryStats(String ownerId, {bool forceRefresh = false}) async {
    emit(OwnerSummaryStatsLoading());
    final result = await _useCase.call(ownerId, forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(OwnerSummaryStatsError(
          '${AppStrings.loadFailedMsg}: ${failure.message}')),
      (stats) => emit(OwnerSummaryStatsLoaded(stats)),
    );
  }
}
