import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/usecases/get_appointment_stats_usecase.dart';
import '../../domain/usecases/get_doctor_performance_usecase.dart';
import '../../domain/usecases/get_drug_stats_usecase.dart';
import '../../domain/usecases/get_patient_stats_usecase.dart';
import '../../domain/usecases/get_revenue_summary_usecase.dart';
import '../../domain/usecases/get_template_stats_usecase.dart';
import 'reports_state.dart';

// @injectable
class ReportsCubit extends Cubit<ReportsState> {
  final GetRevenueSummaryUseCase _getRevenueSummary;
  final GetAppointmentStatsUseCase _getAppointmentStats;
  final GetPatientStatsUseCase _getPatientStats;
  final GetDoctorPerformanceUseCase _getDoctorPerformance;
  final GetDrugStatsUseCase _getDrugStats;
  final GetTemplateStatsUseCase _getTemplateStats;

  ReportsCubit(
    this._getRevenueSummary,
    this._getAppointmentStats,
    this._getPatientStats,
    this._getDoctorPerformance,
    this._getDrugStats,
    this._getTemplateStats,
  ) : super(ReportsInitial());

  Future<void> loadReports({String? doctorId}) async {
    emit(ReportsLoading());

    try {
      final results = await Future.wait([
        _getRevenueSummary(doctorId: doctorId),
        _getAppointmentStats(doctorId: doctorId),
        _getPatientStats(doctorId: doctorId),
        _getDoctorPerformance(),
        _getDrugStats(doctorId: doctorId),
        _getTemplateStats(doctorId: doctorId),
      ]);

      final revenueRes = results[0];
      final appointmentRes = results[1];
      final patientRes = results[2];
      final doctorRes = results[3];
      final drugRes = results[4];
      final templateRes = results[5];

      emit(ReportsLoaded(
        revenueSummary: revenueRes.fold((_) => null, (r) => r as dynamic),
        appointmentStats: appointmentRes.fold((_) => null, (r) => r as dynamic),
        patientStats: patientRes.fold((_) => null, (r) => r as dynamic),
        doctorPerformance: doctorRes.fold((_) => [], (r) => r as dynamic),
        drugStats: drugRes.fold((_) => null, (r) => r as dynamic),
        templateStats: templateRes.fold((_) => [], (r) => r as dynamic),
      ));
    } catch (_) {
      emit(ReportsError(AppStrings.loadReportsFailed));
    }
  }

  void changeRange(ReportsDateRange range) {
    if (state is ReportsLoaded) {
      final loaded = state as ReportsLoaded;
      emit(loaded.copyWith(activeRange: range));
    }
  }
}
