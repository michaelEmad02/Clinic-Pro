// ────────────────────────────────────────────────────────
// PrintingSettingsModel — نموذج ترجمة JSONB لإعدادات الطباعة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';

class PrintingSettingsModel extends PrintingSettingsEntity {
  const PrintingSettingsModel({
    super.hideHeader,
    super.hideFooter,
    super.hidePatientInfo,
    super.hideLogo,
    super.hideDoctorInfo,
    super.hideSignature,
    super.footerLine1,
    super.footerLine2,
    super.footerLine3,
    super.defaultPageFormat,
    super.customWidth,
    super.customHeight,
  });

  factory PrintingSettingsModel.fromJson(Map<String, dynamic> json) {
    return PrintingSettingsModel(
      hideHeader: json['hide_header'] as bool? ?? false,
      hideFooter: json['hide_footer'] as bool? ?? false,
      hidePatientInfo: json['hide_patient_info'] as bool? ?? false,
      hideLogo: json['hide_logo'] as bool? ?? false,
      hideDoctorInfo: json['hide_doctor_info'] as bool? ?? false,
      hideSignature: json['hide_signature'] as bool? ?? false,
      footerLine1:
          json['footer_line1'] as String? ?? 'نتمنى لكم دوام الصحة والعافية',
      footerLine2: json['footer_line2'] as String? ?? '',
      footerLine3: json['footer_line3'] as String? ?? '',
      defaultPageFormat: json['default_page_format'] as String? ?? 'A5',
      customWidth: (json['custom_width'] as num?)?.toDouble() ?? 15.0,
      customHeight: (json['custom_height'] as num?)?.toDouble() ?? 20.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hide_header': hideHeader,
      'hide_footer': hideFooter,
      'hide_patient_info': hidePatientInfo,
      'hide_logo': hideLogo,
      'hide_doctor_info': hideDoctorInfo,
      'hide_signature': hideSignature,
      'footer_line1': footerLine1,
      'footer_line2': footerLine2,
      'footer_line3': footerLine3,
      'default_page_format': defaultPageFormat,
      'custom_width': customWidth,
      'custom_height': customHeight,
    };
  }

  factory PrintingSettingsModel.fromEntity(PrintingSettingsEntity entity) {
    return PrintingSettingsModel(
      hideHeader: entity.hideHeader,
      hideFooter: entity.hideFooter,
      hidePatientInfo: entity.hidePatientInfo,
      hideLogo: entity.hideLogo,
      hideDoctorInfo: entity.hideDoctorInfo,
      hideSignature: entity.hideSignature,
      footerLine1: entity.footerLine1,
      footerLine2: entity.footerLine2,
      footerLine3: entity.footerLine3,
      defaultPageFormat: entity.defaultPageFormat,
      customWidth: entity.customWidth,
      customHeight: entity.customHeight,
    );
  }
}
