import 'package:clinic_pro/features/clinics/domain/use_cases/fetch_clinic_staff_use_case.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'fetch_clinic_staff_state.dart';

@injectable
class FetchClinicStaffCubit extends Cubit<FetchClinicStaffState> {
  FetchClinicStaffCubit(this.fetchClinicStaffUseCase)
      : super(FetchClinicStaffInitial());

  final FetchClinicStaffUseCase fetchClinicStaffUseCase;

  Future<void> fetchClinicStaff(String clinicId) async {
    emit(FetchClinicStaffLoading());
    var result = await fetchClinicStaffUseCase.call(clinicId);
    result.fold(
      (error) => emit(FetchClinicStaffFailure(error.message)),
      (staff) => emit(FetchClinicStaffLoaded(staff)),
    );
  }
}
