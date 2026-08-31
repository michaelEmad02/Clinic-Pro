// ────────────────────────────────────────────────────────
// مدير حالة شاشة كل الروشتات (AllPrescriptionsCubit)
// يتعامل مع جلب وتصفية والبحث في قائمة كل الروشتات
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/usecases/get_all_prescriptions_usecase.dart';
import 'all_prescriptions_state.dart';

@injectable
class AllPrescriptionsCubit extends Cubit<AllPrescriptionsState> {
  final GetAllPrescriptionsUseCase _getAllPrescriptionsUseCase;

  String? _currentClinicId;
  String? _currentDoctorId;

  AllPrescriptionsCubit(this._getAllPrescriptionsUseCase)
      : super(const AllPrescriptionsInitial());

  Future<void> loadPrescriptions({
    String? clinicId,
    String? doctorId,
  }) async {
    _currentClinicId = clinicId;
    _currentDoctorId = doctorId;

    emit(const AllPrescriptionsLoading());

    final result = await _getAllPrescriptionsUseCase(
      clinicId: clinicId,
      doctorId: doctorId,
    );

    result.fold(
      (failure) => emit(AllPrescriptionsError(failure.message)),
      (prescriptions) {
        final sortedList = List<PrescriptionEntity>.from(prescriptions)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        emit(AllPrescriptionsLoaded(
          allPrescriptions: sortedList,
          filteredPrescriptions: sortedList,
        ));
      },
    );
  }

  Future<void> refresh() async {
    final currentState = state;
    String currentQuery = '';
    PrescriptionDateFilter currentFilter = PrescriptionDateFilter.all;

    if (currentState is AllPrescriptionsLoaded) {
      currentQuery = currentState.searchQuery;
      currentFilter = currentState.selectedDateFilter;
    }

    final result = await _getAllPrescriptionsUseCase(
      clinicId: _currentClinicId,
      doctorId: _currentDoctorId,
    );

    result.fold(
      (failure) => emit(AllPrescriptionsError(failure.message)),
      (prescriptions) {
        final sortedList = List<PrescriptionEntity>.from(prescriptions)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filtered = _applyFilters(
          prescriptions: sortedList,
          query: currentQuery,
          filter: currentFilter,
        );

        emit(AllPrescriptionsLoaded(
          allPrescriptions: sortedList,
          filteredPrescriptions: filtered,
          searchQuery: currentQuery,
          selectedDateFilter: currentFilter,
        ));
      },
    );
  }

  void search(String query) {
    if (state is! AllPrescriptionsLoaded) return;
    final currentState = state as AllPrescriptionsLoaded;

    final filtered = _applyFilters(
      prescriptions: currentState.allPrescriptions,
      query: query,
      filter: currentState.selectedDateFilter,
    );

    emit(currentState.copyWith(
      searchQuery: query,
      filteredPrescriptions: filtered,
    ));
  }

  void setDateFilter(PrescriptionDateFilter filter) {
    if (state is! AllPrescriptionsLoaded) return;
    final currentState = state as AllPrescriptionsLoaded;

    final filtered = _applyFilters(
      prescriptions: currentState.allPrescriptions,
      query: currentState.searchQuery,
      filter: filter,
    );

    emit(currentState.copyWith(
      selectedDateFilter: filter,
      filteredPrescriptions: filtered,
    ));
  }

  List<PrescriptionEntity> _applyFilters({
    required List<PrescriptionEntity> prescriptions,
    required String query,
    required PrescriptionDateFilter filter,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday % 7));
    final monthStart = DateTime(now.year, now.month, 1);

    return prescriptions.where((p) {
      // 1. فلترة التاريخ
      if (filter != PrescriptionDateFilter.all) {
        try {
          final prescDate = DateTime.parse(p.createdAt);
          if (filter == PrescriptionDateFilter.today) {
            if (prescDate.isBefore(todayStart)) return false;
          } else if (filter == PrescriptionDateFilter.thisWeek) {
            if (prescDate.isBefore(weekStart)) return false;
          } else if (filter == PrescriptionDateFilter.thisMonth) {
            if (prescDate.isBefore(monthStart)) return false;
          }
        } catch (_) {}
      }

      // 2. البحث بالنص
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return true;

      // مطابقة اسم المريض
      final patientName = (p.patientName ?? '').toLowerCase();
      if (patientName.contains(cleanQuery)) return true;

      // مطابقة رقم الهاتف
      final patientPhone = (p.patientPhone ?? '').toLowerCase();
      if (patientPhone.contains(cleanQuery)) return true;

      // مطابقة التشخيص
      final diagnosis = (p.diagnosis ?? '').toLowerCase();
      if (diagnosis.contains(cleanQuery)) return true;
      for (final d in p.diagnoses) {
        if (d.toLowerCase().contains(cleanQuery)) return true;
      }

      // مطابقة اسم الدواء
      for (final item in p.items) {
        final trade = (item.drug?.tradeName ?? '').toLowerCase();
        final generic = (item.drug?.genericName ?? '').toLowerCase();
        if (trade.contains(cleanQuery) || generic.contains(cleanQuery)) {
          return true;
        }
      }

      // مطابقة التاريخ
      if (p.createdAt.contains(cleanQuery)) return true;

      return false;
    }).toList();
  }
}
