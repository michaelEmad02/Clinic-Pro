import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:printing/printing.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/services/i_prescription_pdf_service.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/appointments/presentation/manager/appointments_bloc.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/prescription_screen.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_print_dialog.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';

class PatientPrescriptionCard extends StatelessWidget {
  final PrescriptionEntity prescription;

  const PatientPrescriptionCard({
    super.key,
    required this.prescription,
  });

  Future<void> _onShareWhatsApp(BuildContext context) async {
    AppLoadingOverlay.show(
      context,
      message: AppStrings.isArabic
          ? 'جاري تجهيز الروشتة للمشاركة عبر الواتساب...'
          : 'Preparing prescription for WhatsApp...',
    );
    try {
      final pdfService = sl<IPrescriptionPdfService>();
      final settingsState = context.read<SettingsCubit>().state;
      final clinic = settingsState.clinicEntity;
      final doctor = settingsState.doctorEntity;

      final pdfBytes = await pdfService.generatePrescriptionPdf(
        prescription: prescription,
        clinic: clinic,
        doctor: doctor,
        pageFormat: 'A5',
      );

      if (context.mounted) {
        AppLoadingOverlay.hide(context);
      }

      final safeName = (prescription.patientName?.isNotEmpty == true
              ? prescription.patientName!
              : 'مريض')
          .replaceAll(' ', '_');

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'روشتة_$safeName.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        AppLoadingOverlay.hide(context);
        AppSnackbar.error(
          context,
          message: AppStrings.isArabic
              ? 'تعذر مشاركة الروشتة عبر الواتساب: $e'
              : 'Failed to share prescription via WhatsApp: $e',
        );
      }
    }
  }

  Future<void> _onEditPrescription(BuildContext context) async {
    final appointmentId = prescription.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) {
      AppSnackbar.error(
        context,
        message: AppStrings.unableToFindAppointment,
      );
      return;
    }

    // إظهار حوار تحميل مؤقت
    AppLoadingOverlay.show(context);

    try {
      final appointmentsBloc = sl<AppointmentsBloc>();
      final realAppointment =
          await appointmentsBloc.getAppointmentById(appointmentId);

      if (context.mounted) {
        AppLoadingOverlay.hide(context); // إغلاق حوار التحميل

        if (realAppointment == null) {
          AppSnackbar.error(
            context,
            message: AppStrings.failedToLoadAppointment,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrescriptionScreen(
                appointment: realAppointment,
                isEditing: true,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppLoadingOverlay.hide(context);
        AppSnackbar.error(
          context,
          message: AppStrings.errorLoadingAppointment,
        );
      }
    }
  }

  void _onPreviewPrescription(BuildContext context) {
    PrescriptionPrintDialog.show(
      context,
      prescription: prescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = prescription.createdAt.length >= 10
        ? prescription.createdAt.substring(0, 10)
        : prescription.createdAt;

    final diagnosesList =
        (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty)
            ? prescription.diagnosis!.split(', ')
            : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: context.primary,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.prescriptionDated(dateStr),
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.medication_outlined, size: 13, color: context.primary),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.drugsCount(prescription.items.length),
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: diagnosesList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: diagnosesList.take(3).map((diag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.primaryLightColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: context.primary.withOpacity(0.15)),
                        ),
                        child: Text(
                          diag,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AppStrings.noDiagnosisRecorded,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ─── قسم التشخيصات الكاملة ───
            if (diagnosesList.isNotEmpty) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.medicalDiagnoses,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: diagnosesList.map((diag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.primary.withOpacity(0.25)),
                    ),
                    child: Text(
                      diag,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // ─── قائمة الأدوية الموصوفة ───
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppStrings.prescribedDrugs,
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = prescription.items[index];
                final drug = item.drug;
                final String tradeName =
                    (drug?.tradeName != null && drug!.tradeName!.isNotEmpty)
                        ? drug.tradeName!
                        : (drug?.genericName != null &&
                                drug!.genericName!.isNotEmpty)
                            ? drug.genericName!
                            : AppStrings.prescribedDrugDefault;
                final String genericName =
                    (drug?.tradeName != null && drug!.tradeName!.isNotEmpty)
                        ? (drug.genericName ?? '')
                        : '';
                final frequencyStr = item.frequency != null
                    ? AppStrings.timesDaily(item.frequency!)
                    : (item.timing != null ? DoseTiming.toLocalized(item.timing) : '');
                final durationStr =
                    item.duration != null ? AppStrings.daysCount(item.duration!) : '';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tradeName,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (genericName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                genericName,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        alignment: WrapAlignment.end,
                        children: [
                          if (frequencyStr.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.primaryLightColor.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                frequencyStr,
                                style: AppTextStyles.caption(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (durationStr.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.surfaceColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: context.borderColor),
                              ),
                              child: Text(
                                durationStr,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryLightColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.primary.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 20, color: context.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.notesPrefix(prescription.notes!),
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

          const SizedBox(height: 16),

          // ─── أزرار التحكم والعرض والتعديل والتصدير التفاعلية ───
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _onShareWhatsApp(context),
                icon: const Icon(TablerIcons.brand_whatsapp,
                    size: 18, color: Color(0xFF25D366)),
                label: Text(
                  AppStrings.whatsApp,
                  style: const TextStyle(
                    color: Color(0xFF25D366),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  backgroundColor: context.background,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _onPreviewPrescription(context),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: Text(AppStrings.print),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  side: BorderSide(color: context.primary),
                  foregroundColor: context.primary,
                  backgroundColor: context.background,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _onEditPrescription(context),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(AppStrings.editPrescription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
