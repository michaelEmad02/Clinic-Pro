part of 'fetch_clinic_staff_cubit.dart';

sealed class FetchClinicStaffState extends Equatable {
  const FetchClinicStaffState();

  @override
  List<Object> get props => [];
}

final class FetchClinicStaffInitial extends FetchClinicStaffState {}

final class FetchClinicStaffLoading extends FetchClinicStaffState {}

final class FetchClinicStaffLoaded extends FetchClinicStaffState {
  final List<StaffEntity> clinicStaff;

  const FetchClinicStaffLoaded(this.clinicStaff);
}

final class FetchClinicStaffFailure extends FetchClinicStaffState {
  final String message;

  const FetchClinicStaffFailure(this.message);
}
