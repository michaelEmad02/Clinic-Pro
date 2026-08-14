import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/get_appointment_stats_usecase.dart';
import 'reports_state.dart';

abstract class AppointmentReportsState extends Equatable {
  const AppointmentReportsState();
  @override
  List<Object?> get props => [];
}

class AppointmentReportsInitial extends AppointmentReportsState {}

class AppointmentReportsLoading extends AppointmentReportsState {}

class AppointmentReportsLoaded extends AppointmentReportsState {
  final AppointmentStatsEntity stats;
  final ReportsDateRange activeRange;
  final DateTimeRange? customDateRange;
  final String? selectedClinicId;

  const AppointmentReportsLoaded({
    required this.stats,
    this.activeRange = ReportsDateRange.thisMonth,
    this.customDateRange,
    this.selectedClinicId,
  });

  AppointmentReportsLoaded copyWith({
    AppointmentStatsEntity? stats,
    ReportsDateRange? activeRange,
    DateTimeRange? customDateRange,
    String? selectedClinicId,
    bool clearClinicId = false,
  }) {
    return AppointmentReportsLoaded(
      stats: stats ?? this.stats,
      activeRange: activeRange ?? this.activeRange,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedClinicId:
          clearClinicId ? null : (selectedClinicId ?? this.selectedClinicId),
    );
  }

  @override
  List<Object?> get props => [
        stats,
        activeRange,
        customDateRange,
        selectedClinicId,
      ];
}

class AppointmentReportsError extends AppointmentReportsState {
  final String message;
  const AppointmentReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class AppointmentReportsCubit extends Cubit<AppointmentReportsState> {
  final GetAppointmentStatsUseCase _getAppointmentStats;

  AppointmentReportsCubit(this._getAppointmentStats)
      : super(AppointmentReportsInitial());

  Future<void> loadReports({
    String? doctorId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    String? clinicId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is AppointmentReportsLoaded) return;

    emit(AppointmentReportsLoading());

    final result = await _getAppointmentStats(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => emit(AppointmentReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(AppointmentReportsLoaded(
        stats: data,
        activeRange: range,
        customDateRange: customDateRange,
        selectedClinicId: clinicId,
      )),
    );
  }

  Future<void> changeRange(
    ReportsDateRange range, {
    String? doctorId,
    DateTimeRange? customDateRange,
  }) async {
    final currentClinicId = state is AppointmentReportsLoaded
        ? (state as AppointmentReportsLoaded).selectedClinicId
        : null;

    emit(AppointmentReportsLoading());

    final result = await _getAppointmentStats(
      doctorId: doctorId,
      clinicId: currentClinicId,
      range: range,
      customDateRange: customDateRange,
    );

    result.fold(
      (failure) => emit(AppointmentReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(AppointmentReportsLoaded(
        stats: data,
        activeRange: range,
        customDateRange: customDateRange,
        selectedClinicId: currentClinicId,
      )),
    );
  }

  Future<void> changeClinic(
    String? clinicId, {
    String? doctorId,
  }) async {
    ReportsDateRange activeRange = ReportsDateRange.thisMonth;
    DateTimeRange? customDateRange;

    if (state is AppointmentReportsLoaded) {
      final current = state as AppointmentReportsLoaded;
      activeRange = current.activeRange;
      customDateRange = current.customDateRange;
    }

    emit(AppointmentReportsLoading());

    final result = await _getAppointmentStats(
      doctorId: doctorId,
      clinicId: clinicId,
      range: activeRange,
      customDateRange: customDateRange,
    );

    result.fold(
      (failure) => emit(AppointmentReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(AppointmentReportsLoaded(
        stats: data,
        activeRange: activeRange,
        customDateRange: customDateRange,
        selectedClinicId: clinicId,
      )),
    );
  }

  void clear() {
    emit(AppointmentReportsInitial());
  }
}
