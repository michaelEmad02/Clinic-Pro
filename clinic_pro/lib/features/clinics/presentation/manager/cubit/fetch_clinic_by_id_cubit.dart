import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/domain/use_cases/fetch_clinic_by_id_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'fetch_clinic_by_id_state.dart';

@injectable
class FetchClinicByIdCubit extends Cubit<FetchClinicByIdState> {
  FetchClinicByIdCubit(this.fetchClinicByIdUseCase)
      : super(FetchClinicByIdInitial());
  final FetchClinicByIdUseCase fetchClinicByIdUseCase;

  Future<void> fetchClinicById(String id) async {
    emit(FetchClinicByIdILoadind());
    final result = await fetchClinicByIdUseCase.call(id);
    result.fold((failure) => emit(FetchClinicByIdFailure(failure.message)),
        (clinic) => emit(FetchClinicByIdLoaded(clinic)));
  }
}
