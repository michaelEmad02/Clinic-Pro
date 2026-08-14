import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import 'package:flutter/material.dart';
import '../../presentation/manager/reports_state.dart';
import '../../domain/usecases/get_doctor_performance_usecase.dart';

abstract class DoctorPerformanceState extends Equatable {
  const DoctorPerformanceState();
  @override
  List<Object?> get props => [];
}

class DoctorPerformanceInitial extends DoctorPerformanceState {}
class DoctorPerformanceLoading extends DoctorPerformanceState {}
class DoctorPerformanceLoaded extends DoctorPerformanceState {
  final List<DoctorPerformanceEntity> doctors;
  final String? selectedClinicId;
  final ReportsDateRange activeRange;
  final DateTimeRange? customDateRange;

  const DoctorPerformanceLoaded({
    required this.doctors,
    this.selectedClinicId,
    this.activeRange = ReportsDateRange.thisMonth,
    this.customDateRange,
  });

  @override
  List<Object?> get props => [doctors, selectedClinicId, activeRange, customDateRange];
}
class DoctorPerformanceError extends DoctorPerformanceState {
  final String message;
  const DoctorPerformanceError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class DoctorPerformanceCubit extends Cubit<DoctorPerformanceState> {
  final GetDoctorPerformanceUseCase _getDoctorPerformance;

  DoctorPerformanceCubit(this._getDoctorPerformance) : super(DoctorPerformanceInitial());

  Future<void> loadReports({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is DoctorPerformanceLoaded) return;

    emit(DoctorPerformanceLoading());
    final result = await _getDoctorPerformance(
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(DoctorPerformanceError(AppStrings.loadReportsFailed)),
      (data) => emit(DoctorPerformanceLoaded(
        doctors: data,
        selectedClinicId: clinicId,
        activeRange: range,
        customDateRange: customDateRange,
      )),
    );
  }

  Future<void> changeClinic(String? clinicId) async {
    ReportsDateRange activeRange = ReportsDateRange.thisMonth;
    DateTimeRange? customDateRange;

    if (state is DoctorPerformanceLoaded) {
      final current = state as DoctorPerformanceLoaded;
      activeRange = current.activeRange;
      customDateRange = current.customDateRange;
    }

    emit(DoctorPerformanceLoading());
    final result = await _getDoctorPerformance(
      clinicId: clinicId,
      range: activeRange,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(DoctorPerformanceError(AppStrings.loadReportsFailed)),
      (data) => emit(DoctorPerformanceLoaded(
        doctors: data,
        selectedClinicId: clinicId,
        activeRange: activeRange,
        customDateRange: customDateRange,
      )),
    );
  }

  Future<void> changeRange(
    ReportsDateRange range, {
    DateTimeRange? customDateRange,
  }) async {
    final currentClinicId = state is DoctorPerformanceLoaded
        ? (state as DoctorPerformanceLoaded).selectedClinicId
        : null;

    emit(DoctorPerformanceLoading());
    final result = await _getDoctorPerformance(
      clinicId: currentClinicId,
      range: range,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(DoctorPerformanceError(AppStrings.loadReportsFailed)),
      (data) => emit(DoctorPerformanceLoaded(
        doctors: data,
        selectedClinicId: currentClinicId,
        activeRange: range,
        customDateRange: customDateRange,
      )),
    );
  }
}
