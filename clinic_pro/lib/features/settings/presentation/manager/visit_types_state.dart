// ────────────────────────────────────────────────────────
// VisitTypesState — يمثل حالة شاشة تعديل أسعار زيارات الطبيب
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';

class VisitTypesState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<DoctorAppointmentTypeEntity> addedEntries;
  final List<Map<String, dynamic>> availableTypes;

  const VisitTypesState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.addedEntries = const [],
    this.availableTypes = const [],
  });

  VisitTypesState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    List<DoctorAppointmentTypeEntity>? addedEntries,
    List<Map<String, dynamic>>? availableTypes,
  }) {
    return VisitTypesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      addedEntries: addedEntries ?? this.addedEntries,
      availableTypes: availableTypes ?? this.availableTypes,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, error, addedEntries, availableTypes];
}
