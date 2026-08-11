// ────────────────────────────────────────────────────────
// PrescriptionPdfCubit — Cubit مسؤول عن إدارة توليد ملفات الـ PDF للروشتة
// يعتمد على GeneratePrescriptionPdfUseCase دون تدخل الـ UI Widget المباشر
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/domain/usecases/generate_prescription_pdf_usecase.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_owner_printing_settings_usecase.dart';
import 'prescription_pdf_state.dart';

@injectable
class PrescriptionPdfCubit extends Cubit<PrescriptionPdfState> {
  final GeneratePrescriptionPdfUseCase _generatePrescriptionPdfUseCase;
  final GetOwnerPrintingSettingsUseCase _getOwnerPrintingSettingsUseCase;

  PrescriptionPdfCubit(
    this._generatePrescriptionPdfUseCase,
    this._getOwnerPrintingSettingsUseCase,
  ) : super(const PrescriptionPdfState());

  /// توليد الـ PDF للروشتة وإرجاع النتيجة مباشرة لـ PdfPreview
  Future<Uint8List> generatePdf({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    String pageFormat = 'A4',
    double? customWidth,
    double? customHeight,
  }) async {
    emit(state.copyWith(status: PrescriptionPdfStatus.loading));

    PrintingSettingsEntity? finalPrintingSettings = printingSettings;

    // جلب إعدادات طباعة المالك إذا لم تكن ممررة مسبقاً
    if (finalPrintingSettings == null) {
      final ownerId = clinic?.ownerId ?? doctor?.userId ?? '';
      if (ownerId.isNotEmpty) {
        final settingsResult =
            await _getOwnerPrintingSettingsUseCase(ownerId, false);
        settingsResult.fold(
          (_) {},
          (settings) {
            finalPrintingSettings = settings;
            emit(state.copyWith(printingSettings: settings));
          },
        );
      }
    }

    final result = await _generatePrescriptionPdfUseCase(
      prescription: prescription,
      clinic: clinic,
      doctor: doctor,
      patient: patient,
      printingSettings: finalPrintingSettings,
      includeHeader: includeHeader,
      pageFormat: pageFormat,
      customWidth: customWidth,
      customHeight: customHeight,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: PrescriptionPdfStatus.error,
          errorMessage: failure.message,
        ));
        return Uint8List(0);
      },
      (pdfBytes) {
        emit(state.copyWith(
          status: PrescriptionPdfStatus.success,
          pdfBytes: pdfBytes,
        ));
        return pdfBytes;
      },
    );
  }

  /// تحميل إعدادات الطباعة الخاصة بالمالك وتحديث الحالة
  Future<void> loadPrintingSettings(String ownerId) async {
    if (ownerId.isEmpty) return;
    emit(state.copyWith(status: PrescriptionPdfStatus.loading));
    final result = await _getOwnerPrintingSettingsUseCase(ownerId, false);
    result.fold(
      (failure) => emit(state.copyWith(
        status: PrescriptionPdfStatus.error,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: PrescriptionPdfStatus.initial,
        printingSettings: settings,
      )),
    );
  }
}
