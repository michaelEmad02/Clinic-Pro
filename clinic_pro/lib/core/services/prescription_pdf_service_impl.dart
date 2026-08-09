// ────────────────────────────────────────────────────────
// تنفيذ خدمة طباعة الروشتة الطبية وتوليد ملفات PDF
// تعتمد على مكتبتي pdf و printing مع دعم الخطوط العربية و الاتجاه RTL
// (Pure Renderer - لا تتواصل مع مصادر البيانات ولا الاستدلالات)
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:clinic_pro/core/services/i_prescription_pdf_service.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

@LazySingleton(as: IPrescriptionPdfService)
class PrescriptionPdfServiceImpl implements IPrescriptionPdfService {
  @override
  Future<Uint8List> generatePrescriptionPdf({
    required PrescriptionEntity prescription,
    ClinicEntity? clinic,
    StaffEntity? doctor,
    PatientEntity? patient,
    PrintingSettingsEntity? printingSettings,
    bool includeHeader = true,
    bool isA5Format = false,
  }) async {
    final pdf = pw.Document();

    final showHeader = includeHeader && (printingSettings?.hideHeader != true);
    final showFooter = printingSettings?.hideFooter != true;
    final showLogo = printingSettings?.hideLogo != true;
    final showDoctorInfo = printingSettings?.hideDoctorInfo != true;
    final showPatientInfo = printingSettings?.hidePatientInfo != true;
    final showSignature = printingSettings?.hideSignature != true;

    // تحميل الخط العربي المناسب لدعم الاتجاه RTL
    final fontData = await PdfGoogleFonts.cairoRegular();
    final fontBoldData = await PdfGoogleFonts.cairoBold();

    final formatChoice = printingSettings?.defaultPageFormat ?? (isA5Format ? 'A5' : 'A4');
    final pageFormat = (formatChoice == 'A5') ? PdfPageFormat.a5 : PdfPageFormat.a4;
    final dateStr = prescription.createdAt.length >= 10
        ? prescription.createdAt.substring(0, 10)
        : prescription.createdAt;

    final clinicName = clinic?.name.isNotEmpty == true
        ? clinic!.name
        : 'عيادة كلينيك برو الطبية';
    final clinicPhone = clinic?.phone1.isNotEmpty == true
        ? clinic!.phone1
        : (clinic?.phone2.isNotEmpty == true ? clinic!.phone2 : '');
    final clinicAddress = clinic?.address ?? '';

    final doctorName = doctor?.name.isNotEmpty == true ? doctor!.name : '';

    final doctorSpecialty = doctor?.specialty?.isNotEmpty == true
        ? doctor!.specialty!
        : 'استشاري الطب والتخصص';
    final doctorPhone = doctor?.phone.isNotEmpty == true ? doctor!.phone : '';

    // ─── جلب صورة شعار العيادة إن وُجد رابطها وكان الشعار مفعلاً ───
    pw.ImageProvider? logoImage;
    final logoUrl = clinic?.logoUrl;
    if (showLogo && logoUrl != null && logoUrl.trim().isNotEmpty) {
      try {
        logoImage = await networkImage(logoUrl.trim());
      } catch (_) {}
    }

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        theme: pw.ThemeData.withFont(
          base: fontData,
          bold: fontBoldData,
        ),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── ترويسة العيادة والشعار والطبيب ───
              if (showHeader) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // جهة اليمين: بيانات العيادة ومعها الشعار إن وُجد
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            width: 50,
                            height: 50,
                            margin: const pw.EdgeInsets.only(left: 10),
                            child: pw.ClipOval(
                              child: pw.Image(
                                logoImage,
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              clinicName,
                              style: pw.TextStyle(
                                fontSize: 15,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.teal800,
                              ),
                            ),
                            if (clinicAddress.isNotEmpty)
                              pw.Text(
                                clinicAddress,
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey700),
                              ),
                            if (clinicPhone.isNotEmpty)
                              pw.Text(
                                'هاتف العيادة: $clinicPhone',
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey700),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // جهة اليسار: بيانات الطبيب (إن لم تكن مخفية)
                    if (showDoctorInfo)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'طبيب المعالجة',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.Text(
                            doctorName.isNotEmpty
                                ? 'د. $doctorName'
                                : 'د. طبيب المعالجة',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.Text(
                            doctorSpecialty,
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700),
                          ),
                          if (doctorPhone.isNotEmpty)
                            pw.Text(
                              'هاتف الطبيب: $doctorPhone',
                              style: const pw.TextStyle(
                                  fontSize: 9, color: PdfColors.grey700),
                            ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1.5, color: PdfColors.teal700),
                pw.SizedBox(height: 8),
              ] else ...[
                // ترك مساحة فارغة علوية تناسب الورق المروّس الجاهز
                pw.SizedBox(height: 60),
              ],

              // ─── شريط بيانات المريض والتاريخ الحقيقي ───
              if (showPatientInfo) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'اسم المريض: ${patient?.name ?? 'مريض العيادة'}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                      if (patient?.gender != null)
                        pw.Text(
                          'الجنس: ${patient!.gender == 'male' ? 'ذكر' : 'أنثى'}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      if (patient?.dateOfBirth != null &&
                          patient!.dateOfBirth!.isNotEmpty)
                        pw.Text(
                          'الميلاد: ${patient.dateOfBirth}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      pw.Text(
                        'التاريخ: $dateStr',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
              ],

              // ─── جدول الأدوية الموصوفة ───
              pw.TableHelper.fromTextArray(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.teal700),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                headers: ['#', 'اسم الدواء', 'التكرار', 'المدة', 'الموعد'],
                data: List.generate(prescription.items.length, (index) {
                  final item = prescription.items[index];
                  final name = item.drug?.tradeName ?? 'دواء موصوف';
                  final freq = item.frequency != null
                      ? '${item.frequency}'
                      : (item.timing ?? '-');
                  final duration =
                      item.duration != null ? '${item.duration} أيام' : '-';
                  final timing = DoseTiming.toArabic(item.timing);

                  return [
                    '${index + 1}',
                    name,
                    freq,
                    duration,
                    timing,
                  ];
                }),
              ),

              if (prescription.notes != null &&
                  prescription.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'تعليمات إضافية: ${prescription.notes}',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey800),
                  ),
                ),
              ],

              pw.Spacer(),

              // ─── تذييل الروشتة والتوقيع وبيانات الطبيب ───
              if (showFooter) ...[
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // أسطر التذييل المخصصة للمالك
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          printingSettings?.footerLine1.isNotEmpty == true
                              ? printingSettings!.footerLine1
                              : 'نتمنى لكم دوام الصحة والعافية',
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700),
                        ),
                        if (printingSettings?.footerLine2.isNotEmpty == true)
                          pw.Text(
                            printingSettings!.footerLine2,
                            style: const pw.TextStyle(
                                fontSize: 8, color: PdfColors.grey600),
                          ),
                        if (printingSettings?.footerLine3.isNotEmpty == true)
                          pw.Text(
                            printingSettings!.footerLine3,
                            style: const pw.TextStyle(
                                fontSize: 8, color: PdfColors.grey600),
                          ),
                      ],
                    ),
                    if (showSignature)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            doctorName.isNotEmpty
                                ? 'د. $doctorName'
                                : 'توقيع/ختم الطبيب',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'التوقيع: .....................',
                            style: const pw.TextStyle(
                                fontSize: 8, color: PdfColors.grey500),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
