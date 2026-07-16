part of 'fetch_clinic_statistics_cubit.dart';

sealed class FetchClinicStatisticsState extends Equatable {
  const FetchClinicStatisticsState();

  @override
  List<Object> get props => [];
}

final class FetchClinicStatisticsInitial extends FetchClinicStatisticsState {}

final class FetchClinicStatisticsLoading extends FetchClinicStatisticsState {}

final class FetchClinicStatisticsLoaded extends FetchClinicStatisticsState {
  final ClinicStatisticsEntity clinicStatistics;

  const FetchClinicStatisticsLoaded(this.clinicStatistics);
}

final class FetchClinicStatisticsFailure extends FetchClinicStatisticsState {
  final String message;

  const FetchClinicStatisticsFailure(this.message);
}
