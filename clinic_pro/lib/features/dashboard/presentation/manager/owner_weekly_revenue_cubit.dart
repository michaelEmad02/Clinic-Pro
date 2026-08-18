// ─────────────────────────────────────────
// Cubit إيراد الأسبوع لمخطط المالك (Weekly Revenue Cubit)
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/usecases/get_owner_weekly_revenue_usecase.dart';
import 'owner_weekly_revenue_state.dart';

@injectable
class OwnerWeeklyRevenueCubit extends Cubit<OwnerWeeklyRevenueState> {
  final GetOwnerWeeklyRevenueUseCase _useCase;

  OwnerWeeklyRevenueCubit(this._useCase) : super(OwnerWeeklyRevenueInitial());

  void loadWeeklyRevenue(String ownerId, {bool forceRefresh = false}) async {
    emit(OwnerWeeklyRevenueLoading());
    final result = await _useCase.call(ownerId, forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(OwnerWeeklyRevenueError('${AppStrings.loadFailedMsg}: ${failure.message}')),
      (revenue) => emit(OwnerWeeklyRevenueLoaded(revenue)),
    );
  }
}
