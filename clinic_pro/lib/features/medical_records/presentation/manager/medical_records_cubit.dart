// ────────────────────────────────────────────────────────
// متحكم السجلات الطبية (MedicalRecordsCubit)
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/delete_medical_record_use_case.dart';
import '../../domain/usecases/get_medical_records_use_case.dart';
import '../../domain/usecases/upload_medical_record_use_case.dart';
import 'medical_records_state.dart';

@injectable
class MedicalRecordsCubit extends Cubit<MedicalRecordsState> {
  final GetMedicalRecordsUseCase _getMedicalRecordsUseCase;
  final UploadMedicalRecordUseCase _uploadMedicalRecordUseCase;
  final DeleteMedicalRecordUseCase _deleteMedicalRecordUseCase;

  MedicalRecordsCubit(
    this._getMedicalRecordsUseCase,
    this._uploadMedicalRecordUseCase,
    this._deleteMedicalRecordUseCase,
  ) : super(MedicalRecordsInitial());

  /// تحميل جميع سجلات وفحوصات المريض
  Future<void> loadRecords(String patientId) async {
    emit(MedicalRecordsLoading());

    final result = await _getMedicalRecordsUseCase(patientId: patientId);

    result.fold(
      (failure) => emit(MedicalRecordsError(failure.message)),
      (records) => emit(MedicalRecordsLoaded(records: records)),
    );
  }

  /// تغيير تصفية العرض (الكل / تحاليل / أشعة)
  void setFilter(String filter) {
    if (state is MedicalRecordsLoaded) {
      final loaded = state as MedicalRecordsLoaded;
      emit(loaded.copyWith(selectedFilter: filter));
    }
  }

  /// رفع فحص طبي جديد وإضافته للقائمة المعروضة
  Future<bool> uploadRecord({
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    required String type,
    required String title,
    required File imageFile,
    required String recordDate,
    String? notes,
  }) async {
    if (state is MedicalRecordsLoaded) {
      final loaded = state as MedicalRecordsLoaded;
      emit(loaded.copyWith(isUploading: true));
    }

    final result = await _uploadMedicalRecordUseCase(
      clinicId: clinicId,
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      prescriptionId: prescriptionId,
      type: type,
      title: title,
      imageFile: imageFile,
      recordDate: recordDate,
      notes: notes,
    );

    return result.fold(
      (failure) {
        if (state is MedicalRecordsLoaded) {
          final loaded = state as MedicalRecordsLoaded;
          emit(loaded.copyWith(
            isUploading: false,
            operationMessage: failure.message,
          ));
        } else {
          emit(MedicalRecordsError(failure.message));
        }
        return false;
      },
      (newRecord) {
        if (state is MedicalRecordsLoaded) {
          final loaded = state as MedicalRecordsLoaded;
          final updatedList = [newRecord, ...loaded.records];
          emit(loaded.copyWith(
            records: updatedList,
            isUploading: false,
            operationMessage: 'تم رفع الفحص الطبي بنجاح',
          ));
        } else {
          emit(MedicalRecordsLoaded(records: [newRecord]));
        }
        return true;
      },
    );
  }

  /// حذف فحص طبي
  Future<bool> deleteRecord({
    required String recordId,
    required String storagePath,
  }) async {
    final result = await _deleteMedicalRecordUseCase(
      recordId: recordId,
      storagePath: storagePath,
    );

    return result.fold(
      (failure) {
        if (state is MedicalRecordsLoaded) {
          final loaded = state as MedicalRecordsLoaded;
          emit(loaded.copyWith(operationMessage: failure.message));
        }
        return false;
      },
      (_) {
        if (state is MedicalRecordsLoaded) {
          final loaded = state as MedicalRecordsLoaded;
          final updatedList = loaded.records.where((r) => r.id != recordId).toList();
          emit(loaded.copyWith(
            records: updatedList,
            operationMessage: 'تم حذف الفحص الطبي بنجاح',
          ));
        }
        return true;
      },
    );
  }
}
