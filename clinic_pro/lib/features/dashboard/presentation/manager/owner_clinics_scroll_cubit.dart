// ─────────────────────────────────────────
// Cubit ملخص عيادات المالك (Clinics Overview Cubit)
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/usecases/get_owner_clinics_overview_usecase.dart';
import 'owner_clinics_scroll_state.dart';

@injectable
class OwnerClinicsScrollCubit extends Cubit<OwnerClinicsScrollState> {
  final GetOwnerClinicsOverviewUseCase _useCase;

  OwnerClinicsScrollCubit(this._useCase) : super(OwnerClinicsScrollInitial());

  void loadClinicsOverview(String ownerId, {bool forceRefresh = false}) async {
    emit(OwnerClinicsScrollLoading());
    final result = await _useCase.call(ownerId, forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(OwnerClinicsScrollError(
          '${AppStrings.loadFailedMsg}: ${failure.message}')),
      (clinics) => emit(OwnerClinicsScrollLoaded(clinics)),
    );
  }
}
