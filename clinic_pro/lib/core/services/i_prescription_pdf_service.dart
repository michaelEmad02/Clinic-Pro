// ────────────────────────────────────────────────────────
// واجهة خدمة طباعة الروشتة الطبية وتوليد ملفات PDF
// تقع بداخل طبقة الخدمات الأساسية (core/services)
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';

import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';

abstract class IPrescriptionPdfService {
  /// توليد مستند الروشتة الطباعية بصيغة PDF برسم نقي للبيانات الممررة
  Future<Uint8List> generatePrescriptionPdf({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    String pageFormat = 'A4',
    double? customWidth,
    double? customHeight,
  });
}
