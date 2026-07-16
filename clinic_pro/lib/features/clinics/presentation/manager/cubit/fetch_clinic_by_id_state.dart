part of 'fetch_clinic_by_id_cubit.dart';

sealed class FetchClinicByIdState extends Equatable {
  const FetchClinicByIdState();

  @override
  List<Object> get props => [];
}

final class FetchClinicByIdInitial extends FetchClinicByIdState {}

final class FetchClinicByIdILoadind extends FetchClinicByIdState {}

final class FetchClinicByIdLoaded extends FetchClinicByIdState {
  final ClinicEntity clinic;

  const FetchClinicByIdLoaded(this.clinic);
}

final class FetchClinicByIdFailure extends FetchClinicByIdState {
  final String message;

  const FetchClinicByIdFailure(this.message);
}
