// ────────────────────────────────────────────────────────
// Cubit تفاصيل المريض — يجلب بيانات المريض وزياراته وروشتاته
// يستبدل FutureBuilder + sl<PatientsRepository>() المباشر في الـ UI
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/patients/presentation/manager/patient_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/find_patient_by_id_usecase.dart';
import '../../domain/usecases/get_visits_for_patient_usecase.dart';

// ───────────── Cubit ─────────────

@injectable
class PatientDetailsCubit extends Cubit<PatientDetailsState> {
  final FindPatientByIdUseCase _findPatientByIdUseCase;
  final GetVisitsForPatientUseCase _getVisitsForPatientUseCase;

  PatientDetailsCubit(
    this._findPatientByIdUseCase,
    this._getVisitsForPatientUseCase,
  ) : super(PatientDetailsInitial());

  /// تحميل بيانات المريض الأساسية
  Future<void> loadPatientDetails(String patientId) async {
    emit(PatientDetailsLoading());

    final result = await _findPatientByIdUseCase(patientId);
    result.fold(
      (failure) => emit(PatientDetailsError(failure.message)),
      (patient) {
        emit(PatientDetailsLoaded(patient: patient, visitsLoading: true));
        // تحميل الزيارات بشكل غير متزامن بعد تحميل بيانات المريض
        _loadVisits(patientId);
      },
    );
  }

  /// تحميل زيارات المريض (مواعيد)
  Future<void> _loadVisits(String patientId) async {
    final result = await _getVisitsForPatientUseCase(patientId);

    if (state is PatientDetailsLoaded) {
      final loaded = state as PatientDetailsLoaded;
      result.fold(
        // في حالة فشل جلب الزيارات نُبقي على بيانات المريض مع قائمة فارغة
        (_) => emit(loaded.copyWith(visits: [], visitsLoading: false)),
        (visits) => emit(loaded.copyWith(visits: visits, visitsLoading: false)),
      );
    }
  }

  /// إعادة تحميل الزيارات
  Future<void> refreshVisits(String patientId) async {
    if (state is PatientDetailsLoaded) {
      final loaded = state as PatientDetailsLoaded;
      emit(loaded.copyWith(visitsLoading: true));
      _loadVisits(patientId);
    }
  }
}
