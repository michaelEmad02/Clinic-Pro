import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/get_appointment_stats_usecase.dart';
import '../../domain/usecases/get_drug_stats_usecase.dart';
import '../../domain/usecases/get_patient_stats_usecase.dart';
import '../../domain/usecases/get_revenue_summary_usecase.dart';
import '../../domain/usecases/get_template_stats_usecase.dart';
import 'reports_state.dart';

abstract class DoctorMyReportsState extends Equatable {
  const DoctorMyReportsState();
  @override
  List<Object?> get props => [];
}

class DoctorMyReportsInitial extends DoctorMyReportsState {}
class DoctorMyReportsLoading extends DoctorMyReportsState {}
class DoctorMyReportsLoaded extends DoctorMyReportsState {
  final RevenueSummaryEntity revenueSummary;
  final AppointmentStatsEntity appointmentStats;
  final PatientStatsEntity patientStats;
  final DrugStatsEntity drugStats;
  final List<TemplateStatsEntity> templateStats;
  final ReportsDateRange activeRange;
  final String? selectedClinicId;

  const DoctorMyReportsLoaded({
    required this.revenueSummary,
    required this.appointmentStats,
    required this.patientStats,
    required this.drugStats,
    required this.templateStats,
    this.activeRange = ReportsDateRange.thisMonth,
    this.selectedClinicId,
  });

  DoctorMyReportsLoaded copyWith({
    RevenueSummaryEntity? revenueSummary,
    AppointmentStatsEntity? appointmentStats,
    PatientStatsEntity? patientStats,
    DrugStatsEntity? drugStats,
    List<TemplateStatsEntity>? templateStats,
    ReportsDateRange? activeRange,
    String? selectedClinicId,
    bool clearClinicId = false,
  }) {
    return DoctorMyReportsLoaded(
      revenueSummary: revenueSummary ?? this.revenueSummary,
      appointmentStats: appointmentStats ?? this.appointmentStats,
      patientStats: patientStats ?? this.patientStats,
      drugStats: drugStats ?? this.drugStats,
      templateStats: templateStats ?? this.templateStats,
      activeRange: activeRange ?? this.activeRange,
      selectedClinicId:
          clearClinicId ? null : (selectedClinicId ?? this.selectedClinicId),
    );
  }

  @override
  List<Object?> get props => [
        revenueSummary,
        appointmentStats,
        patientStats,
        drugStats,
        templateStats,
        activeRange,
        selectedClinicId,
      ];
}
class DoctorMyReportsError extends DoctorMyReportsState {
  final String message;
  const DoctorMyReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class DoctorMyReportsCubit extends Cubit<DoctorMyReportsState> {
  final GetRevenueSummaryUseCase _getRevenueSummary;
  final GetAppointmentStatsUseCase _getAppointmentStats;
  final GetPatientStatsUseCase _getPatientStats;
  final GetDrugStatsUseCase _getDrugStats;
  final GetTemplateStatsUseCase _getTemplateStats;

  DoctorMyReportsCubit(
    this._getRevenueSummary,
    this._getAppointmentStats,
    this._getPatientStats,
    this._getDrugStats,
    this._getTemplateStats,
  ) : super(DoctorMyReportsInitial());

  Future<void> loadReports({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && state is DoctorMyReportsLoaded) return;

    emit(DoctorMyReportsLoading());
    try {
      final results = await Future.wait([
        _getRevenueSummary(doctorId: doctorId, clinicId: clinicId, range: range),
        _getAppointmentStats(doctorId: doctorId, clinicId: clinicId, range: range),
        _getPatientStats(doctorId: doctorId, clinicId: clinicId, range: range),
        _getDrugStats(doctorId: doctorId),
        _getTemplateStats(doctorId: doctorId),
      ]);

      RevenueSummaryEntity? rev;
      AppointmentStatsEntity? appt;
      PatientStatsEntity? pat;
      DrugStatsEntity? drug;
      List<TemplateStatsEntity> tpl = [];

      results[0].fold((_) => null, (r) => rev = r as RevenueSummaryEntity);
      results[1].fold((_) => null, (r) => appt = r as AppointmentStatsEntity);
      results[2].fold((_) => null, (r) => pat = r as PatientStatsEntity);
      results[3].fold((_) => null, (r) => drug = r as DrugStatsEntity);
      results[4].fold((_) => null, (r) => tpl = r as List<TemplateStatsEntity>);

      if (rev != null && appt != null && pat != null && drug != null) {
        emit(DoctorMyReportsLoaded(
          revenueSummary: rev!,
          appointmentStats: appt!,
          patientStats: pat!,
          drugStats: drug!,
          templateStats: tpl,
          activeRange: range,
          selectedClinicId: clinicId,
        ));
      } else {
        emit(DoctorMyReportsError(AppStrings.loadReportsFailed));
      }
    } catch (_) {
      emit(DoctorMyReportsError(AppStrings.loadReportsFailed));
    }
  }

  Future<void> changeClinic(String? clinicId, {String? doctorId}) async {
    ReportsDateRange activeRange = ReportsDateRange.thisMonth;
    if (state is DoctorMyReportsLoaded) {
      activeRange = (state as DoctorMyReportsLoaded).activeRange;
    }
    await loadReports(
      doctorId: doctorId,
      clinicId: clinicId,
      range: activeRange,
      forceRefresh: true,
    );
  }

  Future<void> changeRange(ReportsDateRange range, {String? doctorId}) async {
    String? clinicId;
    if (state is DoctorMyReportsLoaded) {
      clinicId = (state as DoctorMyReportsLoaded).selectedClinicId;
    }
    await loadReports(
      doctorId: doctorId,
      clinicId: clinicId,
      range: range,
      forceRefresh: true,
    );
  }

  void clear() {
    emit(DoctorMyReportsInitial());
  }
}
