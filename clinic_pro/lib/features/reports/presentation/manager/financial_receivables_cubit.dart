// ────────────────────────────────────────────────────────
// FinancialReceivablesCubit — متحكم حالة تقرير المستحقات المالية
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_financial_receivables_report_usecase.dart';
import 'financial_receivables_state.dart';
import 'reports_state.dart';

@injectable
class FinancialReceivablesCubit extends Cubit<FinancialReceivablesState> {
  final GetFinancialReceivablesReportUseCase _getFinancialReceivablesReportUseCase;

  FinancialReceivablesCubit(this._getFinancialReceivablesReportUseCase)
      : super(const FinancialReceivablesState());

  /// تحميل تقرير المستحقات المالية
  Future<void> loadReport({
    String? ownerId,
    bool resetClinic = false,
    String? clinicId,
    bool resetDoctor = false,
    String? doctorId,
    ReportsDateRange? range,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    final newClinicId = resetClinic ? clinicId : (clinicId ?? state.selectedClinicId);
    final newDoctorId = resetDoctor ? doctorId : (doctorId ?? state.selectedDoctorId);

    emit(state.copyWith(
      status: FinancialReceivablesStatus.loading,
      selectedOwnerId: ownerId ?? state.selectedOwnerId,
      selectedClinicId: newClinicId,
      selectedDoctorId: newDoctorId,
      activeDateRange: range ?? state.activeDateRange,
      customDateRange: customDateRange ?? state.customDateRange,
    ));

    final result = await _getFinancialReceivablesReportUseCase(
      ownerId: state.selectedOwnerId,
      clinicId: newClinicId,
      doctorId: newDoctorId,
      range: state.activeDateRange,
      customDateRange: state.customDateRange,
      forceRefresh: forceRefresh,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FinancialReceivablesStatus.error,
        errorMessage: failure.message,
      )),
      (report) => emit(state.copyWith(
        status: FinancialReceivablesStatus.loaded,
        report: report,
      )),
    );
  }

  /// تغيير التبويبات (0: كشف حساب المرضى المديونين، 1: كشف تفاصيل المستحقات)
  void changeTab(int index) {
    emit(state.copyWith(activeTab: index));
  }

  /// تغيير البحث باسم المريض
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// تغيير فلتر نوع المستحق (0: الكل، 1: فواتير معلقة فقط، 2: زيارات غير مفوترة فقط)
  void setTypeFilter(int filter) {
    emit(state.copyWith(typeFilter: filter));
  }
}
