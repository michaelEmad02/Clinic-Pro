import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/get_drug_stats_usecase.dart';
import 'reports_state.dart';

abstract class DrugReportsState extends Equatable {
  const DrugReportsState();
  @override
  List<Object?> get props => [];
}

class DrugReportsInitial extends DrugReportsState {}
class DrugReportsLoading extends DrugReportsState {}
class DrugReportsLoaded extends DrugReportsState {
  final DrugStatsEntity stats;
  final ReportsDateRange activeRange;
  final String? selectedClinicId;

  const DrugReportsLoaded({
    required this.stats,
    this.activeRange = ReportsDateRange.thisMonth,
    this.selectedClinicId,
  });

  DrugReportsLoaded copyWith({
    DrugStatsEntity? stats,
    ReportsDateRange? activeRange,
    String? selectedClinicId,
    bool clearClinicId = false,
  }) {
    return DrugReportsLoaded(
      stats: stats ?? this.stats,
      activeRange: activeRange ?? this.activeRange,
      selectedClinicId:
          clearClinicId ? null : (selectedClinicId ?? this.selectedClinicId),
    );
  }

  @override
  List<Object?> get props => [stats, activeRange, selectedClinicId];
}
class DrugReportsError extends DrugReportsState {
  final String message;
  const DrugReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class DrugReportsCubit extends Cubit<DrugReportsState> {
  final GetDrugStatsUseCase _getDrugStats;

  DrugReportsCubit(this._getDrugStats) : super(DrugReportsInitial());

  Future<void> loadReports({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is DrugReportsLoaded) return;

    emit(DrugReportsLoading());
    final result = await _getDrugStats(
      doctorId: doctorId,
      clinicId: clinicId,
      forceRefresh: forceRefresh,
    );
    result.fold(
      (failure) => emit(DrugReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(DrugReportsLoaded(
        stats: data,
        selectedClinicId: clinicId,
      )),
    );
  }

  Future<void> changeClinic(String? clinicId, {String? doctorId}) async {
    emit(DrugReportsLoading());
    final result = await _getDrugStats(doctorId: doctorId, clinicId: clinicId);
    result.fold(
      (failure) => emit(DrugReportsError(AppStrings.loadReportsFailed)),
      (data) => emit(DrugReportsLoaded(
        stats: data,
        selectedClinicId: clinicId,
      )),
    );
  }

  Future<void> changeRange(ReportsDateRange range, {String? doctorId}) async {
    if (state is DrugReportsLoaded) {
      final current = state as DrugReportsLoaded;
      emit(current.copyWith(activeRange: range));
    }
  }

  void clear() {
    emit(DrugReportsInitial());
  }
}
