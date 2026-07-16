import 'package:clinic_pro/features/clinics/domain/entities/clinic_statistics_entity.dart';
import 'package:clinic_pro/features/clinics/domain/use_cases/fetch_clinic_statistics_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'fetch_clinic_statistics_state.dart';

@injectable
class FetchClinicStatisticsCubit extends Cubit<FetchClinicStatisticsState> {
  FetchClinicStatisticsCubit(this.fetchClinicStatisticsUseCase)
      : super(FetchClinicStatisticsInitial());
  final FetchClinicStatisticsUseCase fetchClinicStatisticsUseCase;

  Future<void> fetchClinicStatistics(String clinicId) async {
    emit(FetchClinicStatisticsLoading());
    var result = await fetchClinicStatisticsUseCase.call(clinicId);
    result.fold(
        (failure) => emit(FetchClinicStatisticsFailure(failure.message)),
        (statistics) => emit(FetchClinicStatisticsLoaded(statistics)));
  }
}
