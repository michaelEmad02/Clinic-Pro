// ────────────────────────────────────────────────────────
// PrescriptionPdfState — حالة إدارة توليد معينات الـ PDF لروشتات العيادة
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';

enum PrescriptionPdfStatus { initial, loading, success, error }

class PrescriptionPdfState extends Equatable {
  final PrescriptionPdfStatus status;
  final Uint8List? pdfBytes;
  final String? errorMessage;
  final PrintingSettingsEntity? printingSettings;

  const PrescriptionPdfState({
    this.status = PrescriptionPdfStatus.initial,
    this.pdfBytes,
    this.errorMessage,
    this.printingSettings,
  });

  PrescriptionPdfState copyWith({
    PrescriptionPdfStatus? status,
    Uint8List? pdfBytes,
    String? errorMessage,
    PrintingSettingsEntity? printingSettings,
  }) {
    return PrescriptionPdfState(
      status: status ?? this.status,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      errorMessage: errorMessage ?? this.errorMessage,
      printingSettings: printingSettings ?? this.printingSettings,
    );
  }

  @override
  List<Object?> get props => [status, pdfBytes, errorMessage, printingSettings];
}
