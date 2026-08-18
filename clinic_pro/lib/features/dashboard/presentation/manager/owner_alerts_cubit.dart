// ─────────────────────────────────────────
// Cubit التنبيهات الذكية للمالك (Owner Alerts Cubit)
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/usecases/get_owner_alerts_usecase.dart';
import 'owner_alerts_state.dart';

@injectable
class OwnerAlertsCubit extends Cubit<OwnerAlertsState> {
  final GetOwnerAlertsUseCase _useCase;

  OwnerAlertsCubit(this._useCase) : super(OwnerAlertsInitial());

  void loadAlerts(String ownerId, {bool forceRefresh = false}) async {
    emit(OwnerAlertsLoading());
    final result = await _useCase.call(ownerId, forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(
          OwnerAlertsError('${AppStrings.loadFailedMsg}: ${failure.message}')),
      (alerts) => emit(OwnerAlertsLoaded(alerts)),
    );
  }
}
