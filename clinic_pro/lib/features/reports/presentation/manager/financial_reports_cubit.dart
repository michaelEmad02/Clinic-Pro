import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/get_revenue_summary_usecase.dart';
import 'reports_state.dart';

abstract class FinancialReportsState extends Equatable {
  const FinancialReportsState();
  @override
  List<Object?> get props => [];
}

class FinancialReportsInitial extends FinancialReportsState {}
class FinancialReportsLoading extends FinancialReportsState {}
class FinancialReportsLoaded extends FinancialReportsState {
  final RevenueSummaryEntity summary;
  final ReportsDateRange activeRange;
  final DateTimeRange? customDateRange;
  final String? selectedClinicId;

  const FinancialReportsLoaded({
    required this.summary,
    this.activeRange = ReportsDateRange.thisMonth,
    this.customDateRange,
    this.selectedClinicId,
  });

  FinancialReportsLoaded copyWith({
    RevenueSummaryEntity? summary,
    ReportsDateRange? activeRange,
    DateTimeRange? customDateRange,
    String? selectedClinicId,
    bool clearClinicId = false,
  }) {
    return FinancialReportsLoaded(
      summary: summary ?? this.summary,
      activeRange: activeRange ?? this.activeRange,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedClinicId:
          clearClinicId ? null : (selectedClinicId ?? this.selectedClinicId),
    );
  }

  @override
  List<Object?> get props => [summary, activeRange, customDateRange, selectedClinicId];
}
class FinancialReportsError extends FinancialReportsState {
  final String message;
  const FinancialReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class FinancialReportsCubit extends Cubit<FinancialReportsState> {
  final GetRevenueSummaryUseCase _getRevenueSummary;

  FinancialReportsCubit(this._getRevenueSummary) : super(FinancialReportsInitial());

  Future<void> loadReports({
    String? doctorId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    String? clinicId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is FinancialReportsLoaded) return;

    emit(FinancialReportsLoading());
    final result = await _getRevenueSummary(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      customDateRange: customDateRange,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(FinancialReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(FinancialReportsLoaded(
        summary: data,
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
    final currentClinicId = state is FinancialReportsLoaded
        ? (state as FinancialReportsLoaded).selectedClinicId
        : null;

    emit(FinancialReportsLoading());
    final result = await _getRevenueSummary(
      doctorId: doctorId,
      clinicId: currentClinicId,
      range: range,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(FinancialReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(FinancialReportsLoaded(
        summary: data,
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

    if (state is FinancialReportsLoaded) {
      final current = state as FinancialReportsLoaded;
      activeRange = current.activeRange;
      customDateRange = current.customDateRange;
    }

    emit(FinancialReportsLoading());
    final result = await _getRevenueSummary(
      doctorId: doctorId,
      clinicId: clinicId,
      range: activeRange,
      customDateRange: customDateRange,
    );
    result.fold(
      (failure) => emit(FinancialReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(FinancialReportsLoaded(
        summary: data,
        activeRange: activeRange,
        customDateRange: customDateRange,
        selectedClinicId: clinicId,
      )),
    );
  }

  void clear() {
    emit(FinancialReportsInitial());
  }
}
