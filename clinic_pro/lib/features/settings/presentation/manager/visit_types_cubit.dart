// ────────────────────────────────────────────────────────
// VisitTypesCubit — يدير منطق وحالة تسعيرات زيارات الطبيب
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';
import '../../domain/usecases/get_doctor_appointment_types_usecase.dart';
import '../../domain/usecases/get_global_appointment_types_usecase.dart';
import '../../domain/usecases/sync_doctor_appointment_types_usecase.dart';
import 'visit_types_state.dart';

class VisitTypesCubit extends Cubit<VisitTypesState> {
  final GetDoctorAppointmentTypesUseCase _getDoctorAppointmentTypesUseCase;
  final GetGlobalAppointmentTypesUseCase _getGlobalAppointmentTypesUseCase;
  final SyncDoctorAppointmentTypesUseCase _syncDoctorAppointmentTypesUseCase;

  VisitTypesCubit(
    this._getDoctorAppointmentTypesUseCase,
    this._getGlobalAppointmentTypesUseCase,
    this._syncDoctorAppointmentTypesUseCase,
  ) : super(const VisitTypesState());

  /// تحميل البيانات للعيادة والطبيب المحددين
  Future<void> loadData({
    required String doctorId,
    required String clinicId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final globalResult = await _getGlobalAppointmentTypesUseCase();
      final doctorResult = await _getDoctorAppointmentTypesUseCase(
        doctorId: doctorId,
        clinicId: clinicId,
      );

      globalResult.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (globalTypes) {
          doctorResult.fold(
            (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
            (doctorTypes) {
              final usedTypeIds = doctorTypes.map((e) => e.appointmentTypeId).toSet();
              final availableTypes = globalTypes
                  .where((t) => !usedTypeIds.contains(t['id']))
                  .toList();

              emit(state.copyWith(
                isLoading: false,
                addedEntries: doctorTypes,
                availableTypes: availableTypes,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// إضافة كشف جديد للقائمة المؤقتة
  void addEntry({
    required String doctorId,
    required String? clinicId,
    required String typeId,
    required String typeName,
    required double price,
  }) {
    final entry = DoctorAppointmentTypeEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // معرف مؤقت
      doctorId: doctorId,
      clinicId: clinicId,
      appointmentTypeId: typeId,
      name: typeName,
      price: price,
    );

    final updatedAdded = [...state.addedEntries, entry];
    final updatedAvailable = state.availableTypes.where((t) => t['id'] != typeId).toList();

    emit(state.copyWith(
      addedEntries: updatedAdded,
      availableTypes: updatedAvailable,
    ));
  }

  /// حذف كشف من القائمة المؤقتة
  void removeEntry(int index) {
    if (index < 0 || index >= state.addedEntries.length) return;

    final removed = state.addedEntries[index];
    final updatedAdded = [...state.addedEntries]..removeAt(index);

    final updatedAvailable = [...state.availableTypes];
    if (removed.name != null) {
      updatedAvailable.add({
        'id': removed.appointmentTypeId,
        'name': removed.name,
      });
    }

    emit(state.copyWith(
      addedEntries: updatedAdded,
      availableTypes: updatedAvailable,
    ));
  }

  /// حفظ البيانات النهائية في قاعدة البيانات
  Future<void> save({
    required String doctorId,
    required String clinicId,
  }) async {
    emit(state.copyWith(isSaving: true, error: null));

    final result = await _syncDoctorAppointmentTypesUseCase(
      doctorId: doctorId,
      clinicId: clinicId,
      types: state.addedEntries,
    );

    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(isSaving: false)),
    );
  }
}
