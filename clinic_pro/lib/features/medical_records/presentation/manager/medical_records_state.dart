// ────────────────────────────────────────────────────────
// حالات متحكم السجلات الطبية (MedicalRecordsState)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/medical_record_entity.dart';

abstract class MedicalRecordsState extends Equatable {
  const MedicalRecordsState();

  @override
  List<Object?> get props => [];
}

class MedicalRecordsInitial extends MedicalRecordsState {}

class MedicalRecordsLoading extends MedicalRecordsState {}

class MedicalRecordsLoaded extends MedicalRecordsState {
  final List<MedicalRecordEntity> records;
  final String selectedFilter; // 'all', 'lab_test', 'radiology'
  final bool isUploading;
  final String? operationMessage;

  const MedicalRecordsLoaded({
    required this.records,
    this.selectedFilter = 'all',
    this.isUploading = false,
    this.operationMessage,
  });

  /// الفحوصات المصفاة حسب الفلتر الحالي
  List<MedicalRecordEntity> get filteredRecords {
    if (selectedFilter == 'all') return records;
    if (selectedFilter == 'linked') {
      return records.where((r) => r.isLinkedToAppointment).toList();
    }
    if (selectedFilter == 'unlinked') {
      return records.where((r) => !r.isLinkedToAppointment).toList();
    }
    return records.where((r) => r.type == selectedFilter).toList();
  }

  /// عدد التحاليل
  int get labTestsCount =>
      records.where((r) => r.type == MedicalRecordType.labTest).length;

  /// عدد الأشعات
  int get radiologyCount =>
      records.where((r) => r.type == MedicalRecordType.radiology).length;

  /// عدد الفحوصات المرتبطة بموعد
  int get linkedCount =>
      records.where((r) => r.isLinkedToAppointment).length;

  /// عدد الفحوصات المستقلة (بدون موعد)
  int get unlinkedCount =>
      records.where((r) => !r.isLinkedToAppointment).length;

  MedicalRecordsLoaded copyWith({
    List<MedicalRecordEntity>? records,
    String? selectedFilter,
    bool? isUploading,
    String? operationMessage,
  }) {
    return MedicalRecordsLoaded(
      records: records ?? this.records,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isUploading: isUploading ?? this.isUploading,
      operationMessage: operationMessage,
    );
  }

  @override
  List<Object?> get props => [records, selectedFilter, isUploading, operationMessage];
}

class MedicalRecordsError extends MedicalRecordsState {
  final String message;

  const MedicalRecordsError(this.message);

  @override
  List<Object?> get props => [message];
}
