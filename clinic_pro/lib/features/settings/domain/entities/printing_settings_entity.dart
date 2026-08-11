// ────────────────────────────────────────────────────────
// PrintingSettingsEntity — كيان إعدادات طباعة الروشتة المخصصة للمالك
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class PrintingSettingsEntity extends Equatable {
  final bool hideHeader;
  final bool hideFooter;
  final bool hidePatientInfo;
  final bool hideLogo;
  final bool hideDoctorInfo;
  final bool hideSignature;
  final String footerLine1;
  final String footerLine2;
  final String footerLine3;
  final String defaultPageFormat; // 'A5' or 'A4'
  final double customWidth;
  final double customHeight;

  const PrintingSettingsEntity({
    this.hideHeader = false,
    this.hideFooter = false,
    this.hidePatientInfo = false,
    this.hideLogo = false,
    this.hideDoctorInfo = false,
    this.hideSignature = false,
    this.footerLine1 = 'نتمنى لكم دوام الصحة والعافية',
    this.footerLine2 = '',
    this.footerLine3 = '',
    this.defaultPageFormat = 'A5',
    this.customWidth = 15.0,
    this.customHeight = 20.0,
  });

  PrintingSettingsEntity copyWith({
    bool? hideHeader,
    bool? hideFooter,
    bool? hidePatientInfo,
    bool? hideLogo,
    bool? hideDoctorInfo,
    bool? hideSignature,
    String? footerLine1,
    String? footerLine2,
    String? footerLine3,
    String? defaultPageFormat,
    double? customWidth,
    double? customHeight,
  }) {
    return PrintingSettingsEntity(
      hideHeader: hideHeader ?? this.hideHeader,
      hideFooter: hideFooter ?? this.hideFooter,
      hidePatientInfo: hidePatientInfo ?? this.hidePatientInfo,
      hideLogo: hideLogo ?? this.hideLogo,
      hideDoctorInfo: hideDoctorInfo ?? this.hideDoctorInfo,
      hideSignature: hideSignature ?? this.hideSignature,
      footerLine1: footerLine1 ?? this.footerLine1,
      footerLine2: footerLine2 ?? this.footerLine2,
      footerLine3: footerLine3 ?? this.footerLine3,
      defaultPageFormat: defaultPageFormat ?? this.defaultPageFormat,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
    );
  }

  @override
  List<Object?> get props => [
        hideHeader,
        hideFooter,
        hidePatientInfo,
        hideLogo,
        hideDoctorInfo,
        hideSignature,
        footerLine1,
        footerLine2,
        footerLine3,
        defaultPageFormat,
        customWidth,
        customHeight,
      ];
}
