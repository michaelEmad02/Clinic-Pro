import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_prescriptions_for_patient_usecase.dart';
import 'patient_prescriptions_state.dart';

@injectable
class PatientPrescriptionsCubit extends Cubit<PatientPrescriptionsState> {
  final GetPrescriptionsForPatientUseCase _getPrescriptionsForPatientUseCase;

  PatientPrescriptionsCubit(this._getPrescriptionsForPatientUseCase)
      : super(PatientPrescriptionsInitial());

  Future<void> loadPrescriptions(String patientId) async {
    emit(PatientPrescriptionsLoading());

    final result = await _getPrescriptionsForPatientUseCase(patientId);

    result.fold(
      (failure) => emit(PatientPrescriptionsError(failure.message)),
      (prescriptions) => emit(PatientPrescriptionsLoaded(prescriptions)),
    );
  }
}
