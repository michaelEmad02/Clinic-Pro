import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/get_patient_stats_usecase.dart';
import 'reports_state.dart';

abstract class PatientReportsState extends Equatable {
  const PatientReportsState();
  @override
  List<Object?> get props => [];
}

class PatientReportsInitial extends PatientReportsState {}
class PatientReportsLoading extends PatientReportsState {}
class PatientReportsLoaded extends PatientReportsState {
  final PatientStatsEntity stats;
  final ReportsDateRange activeRange;
  final DateTimeRange? customDateRange;
  final String? selectedClinicId;

  const PatientReportsLoaded({
    required this.stats,
    this.activeRange = ReportsDateRange.thisMonth,
    this.customDateRange,
    this.selectedClinicId,
  });

  PatientReportsLoaded copyWith({
    PatientStatsEntity? stats,
    ReportsDateRange? activeRange,
    DateTimeRange? customDateRange,
    String? selectedClinicId,
    bool clearClinicId = false,
  }) {
    return PatientReportsLoaded(
      stats: stats ?? this.stats,
      activeRange: activeRange ?? this.activeRange,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedClinicId:
          clearClinicId ? null : (selectedClinicId ?? this.selectedClinicId),
    );
  }

  @override
  List<Object?> get props => [stats, activeRange, customDateRange, selectedClinicId];
}
class PatientReportsError extends PatientReportsState {
  final String message;
  const PatientReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class PatientReportsCubit extends Cubit<PatientReportsState> {
  final GetPatientStatsUseCase _getPatientStats;

  PatientReportsCubit(this._getPatientStats) : super(PatientReportsInitial());

  Future<void> loadReports({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is PatientReportsLoaded) return;

    emit(PatientReportsLoading());
    final result = await _getPatientStats(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(PatientReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(PatientReportsLoaded(
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
    final currentClinicId = state is PatientReportsLoaded
        ? (state as PatientReportsLoaded).selectedClinicId
        : null;

    emit(PatientReportsLoading());
    final result = await _getPatientStats(
      doctorId: doctorId,
      clinicId: currentClinicId,
      range: range,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(PatientReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(PatientReportsLoaded(
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

    if (state is PatientReportsLoaded) {
      final current = state as PatientReportsLoaded;
      activeRange = current.activeRange;
      customDateRange = current.customDateRange;
    }

    emit(PatientReportsLoading());
    final result = await _getPatientStats(
      doctorId: doctorId,
      clinicId: clinicId,
      range: activeRange,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(PatientReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(PatientReportsLoaded(
        stats: data,
        activeRange: activeRange,
        customDateRange: customDateRange,
        selectedClinicId: clinicId,
      )),
    );
  }

  void clear() {
    emit(PatientReportsInitial());
  }
}
