// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/services/i_prescription_pdf_service.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_bloc.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_event.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_state.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/add_drug_search_sheet.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/drugs_list_section.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_bottom_actions_bar.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_header_card.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_notes_field.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/templates_selector_section.dart';
import 'package:clinic_pro/features/prescription/domain/entities/drug_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_print_dialog.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../../appointments/domain/entities/appointment_entity.dart';
import '../../../../appointments/presentation/manager/appointments_bloc.dart';
import '../../../../appointments/presentation/manager/appointments_event.dart';

import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/services/prescription_pdf_service_impl.dart';
import 'package:clinic_pro/core/widgets/read_only_guard.dart';

class PrescriptionView extends StatelessWidget {
  const PrescriptionView(this.isEditing,
      {super.key, required this.appointment});
  final bool isEditing;
  final AppointmentEntity appointment;

  PrescriptionEntity _buildPrescriptionEntity(PrescriptionState state) {
    final itemsMapped = state.selectedDrugs.map((d) {
      return PrescriptionItemEntity(
        id: d.id,
        prescriptionId: state.prescriptionId,
        drugId: d.id,
        frequency: d.doseFrequency,
        duration: d.doseDuration,
        timing: d.doseTiming,
        isPrn: d.isPrn,
        drug: DrugEntity(
          id: d.id,
          tradeName: d.tradeName,
          genericName: d.genericName,
          category: d.category,
        ),
      );
    }).toList();

    return PrescriptionEntity(
      id: state.prescriptionId,
      createdAt: DateTime.now().toIso8601String(),
      clinicId: appointment.clinicId,
      doctorId: appointment.doctorId,
      patientId: appointment.patientId,
      appointmentId: appointment.id,
      diagnosis: state.finalDiagnosis.trim().isNotEmpty
          ? state.finalDiagnosis.trim()
          : state.selectedDiagnosis.join(' ، '),
      diagnoses: state.selectedDiagnosis,
      notes: state.notes,
      nextVisitDays: state.nextVisitDays,
      items: itemsMapped,
    );
  }

  Future<void> _sharePrescriptionPdf(BuildContext context,
      PrescriptionEntity prescEntity, String patientName) async {
    AppLoadingOverlay.show(
      context,
      message: AppStrings.isArabic
          ? 'جاري تجهيز الروشتة للمشاركة عبر الواتساب...'
          : 'Preparing prescription for WhatsApp...',
    );

    try {
      ClinicEntity? clinic;
      StaffEntity? doctor;
      try {
        final settingsCubit = context.read<SettingsCubit>();
        clinic = settingsCubit.state.clinicEntity;
        doctor = settingsCubit.state.doctor;
      } catch (_) {}

      final pdfService = sl<IPrescriptionPdfService>();
      final pdfBytes = await pdfService.generatePrescriptionPdf(
        prescription: prescEntity,
        clinic: clinic,
        doctor: doctor,
        pageFormat: 'A5',
      );

      if (context.mounted) {
        AppLoadingOverlay.hide(context);
      }

      final safeName =
          (patientName.isNotEmpty ? patientName : 'مريض').replaceAll(' ', '_');
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
              ? 'تعذر مشاركة الروشتة: $e'
              : 'Failed to share prescription: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحميل الخطوط مسبقاً في الذاكرة لتسريع توليد الـ PDF فورياً
    PrescriptionPdfServiceImpl.preloadFonts();

    return BlocConsumer<PrescriptionBloc, PrescriptionState>(
      listener: (context, state) async {
        if (state.status == PrescriptionStatus.loading &&
            state.postSaveAction != PostSaveAction.none) {
          final isWhatsApp = state.postSaveAction == PostSaveAction.whatsapp;
          AppLoadingOverlay.show(
            context,
            message: isWhatsApp
                ? (AppStrings.isArabic
                    ? 'جاري حفظ الروشتة وتجهيز الإرسال عبر الواتساب...'
                    : 'Saving prescription & preparing WhatsApp...')
                : (AppStrings.isArabic
                    ? 'جاري حفظ الروشتة...'
                    : 'Saving prescription...'),
          );
        } else if (state.status == PrescriptionStatus.success) {
          context.read<AppointmentsBloc>().add(
                CompleteAppointmentEvent(
                  appointmentId: appointment.id,
                  calledAt: appointment.calledAt,
                ),
              );

          final prescEntity =
              state.savedPrescription ?? _buildPrescriptionEntity(state);
          final postAction = state.postSaveAction;
          final patientName = state.patientName;

          if (postAction == PostSaveAction.whatsapp) {
            AppLoadingOverlay.hide(context);
            await _sharePrescriptionPdf(context, prescEntity, patientName);
            if (context.mounted) {
              AppSnackbar.success(
                context,
                message: '${AppStrings.addedSuccess} ✓',
              );
              context.pop();
            }
          } else {
            AppLoadingOverlay.hide(context);
            AppSnackbar.success(
              context,
              message: '${AppStrings.addedSuccess} ✓',
            );
            context.pop();

            if (postAction == PostSaveAction.print) {
              PrescriptionPrintDialog.show(
                context,
                prescription: prescEntity,
              );
            }
          }
        } else if (state.status == PrescriptionStatus.error) {
          AppLoadingOverlay.hide(context);
          AppSnackbar.error(
            context,
            message: state.errorMessage ?? AppStrings.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: _buildAppBar(context, state, isEditing),
          body: _buildBody(context, state),
          bottomNavigationBar: state.status == PrescriptionStatus.loaded
              ? PrescriptionBottomActionsBar(
                  onSaveAndFinish: () {
                    ReadOnlyGuard.protect(
                      context,
                      onAllowed: () {
                        context.read<PrescriptionBloc>().add(
                              const SavePrescriptionEvent(
                                  action: PostSaveAction.finish),
                            );
                      },
                    );
                  },
                  onSaveAndPrint: () {
                    ReadOnlyGuard.protect(
                      context,
                      onAllowed: () {
                        context.read<PrescriptionBloc>().add(
                              const SavePrescriptionEvent(
                                  action: PostSaveAction.print),
                            );
                      },
                    );
                  },
                  onSaveAndSend: () {
                    ReadOnlyGuard.protect(
                      context,
                      onAllowed: () {
                        context.read<PrescriptionBloc>().add(
                              const SavePrescriptionEvent(
                                  action: PostSaveAction.whatsapp),
                            );
                      },
                    );
                  },
                  onFinish: () {
                    ReadOnlyGuard.protect(
                      context,
                      onAllowed: () {
                        context.read<AppointmentsBloc>().add(
                              CompleteAppointmentEvent(
                                  appointmentId: appointment.id),
                            );
                        AppSnackbar.success(
                          context,
                          message: AppStrings.isArabic
                              ? 'تم إنهاء الكشف بنجاح ✓'
                              : 'Appointment completed ✓',
                        );
                        context.pop();
                      },
                    );
                  },
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, PrescriptionState state, bool isEditing) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.prescription,
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          if (state.status == PrescriptionStatus.loaded)
            Text(
              state.patientName,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        if (!isEditing)
          TextButton.icon(
            onPressed: () {
              context.read<PrescriptionBloc>().add(
                    const CopyPreviousPrescriptionEvent(),
                  );
              AppSnackbar.success(
                context,
                message: '${AppStrings.prescription} ${AppStrings.success} ✓',
              );
            },
            icon: Icon(Icons.content_copy,
                size: AppConstants.iconSizeLg, color: context.primary),
            label: Text(
              AppStrings.copyLastPrescription,
              style: AppTextStyles.caption(context).copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: AppConstants.spaceSm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: context.borderColor, height: 1),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrescriptionState state) {
    if (state.status == PrescriptionStatus.initial ||
        state.status == PrescriptionStatus.loading) {
      return ResponsiveHelper.responsiveCenter(
        maxWidth: AppConstants.maxContentWidth,
        child: const Padding(
          padding: EdgeInsets.all(AppConstants.spaceMd),
          child: ShimmerList(itemCount: 5),
        ),
      );
    }

    if (state.status == PrescriptionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.danger),
            const SizedBox(height: AppConstants.spaceSm + 4),
            Text(
              state.errorMessage ?? AppStrings.loadFailed,
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(AppStrings.close),
            ),
          ],
        ),
      );
    }

    return ResponsiveHelper.responsiveCenter(
      maxWidth: AppConstants.maxContentWidth,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppConstants.spaceSm),
            PrescriptionHeaderCard(
              patientName: state.patientName,
              age: state.patientAge,
              gender: state.patientGender,
              bloodType: state.bloodType,
              visitType: state.visitType,
              doctorName: state.doctorName,
              visitDate: state.visitDate,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            const TemplatesSelectorSection(),
            const SizedBox(height: AppConstants.spaceSm),
            DrugsListSection(
              selectedDrugs: state.selectedDrugs,
              onUpdateDrug: (drugId,
                  {doseFrequency, doseDuration, doseTiming, isPrn}) {
                context.read<PrescriptionBloc>().add(
                      UpdateDrugDoseEvent(
                        drugId: drugId,
                        doseFrequency: doseFrequency,
                        doseDuration: doseDuration,
                        doseTiming: doseTiming,
                        isPrn: isPrn,
                      ),
                    );
              },
              onRemoveDrug: (drugId) {
                context.read<PrescriptionBloc>().add(
                      RemoveDrugFromPrescriptionEvent(drugId),
                    );
              },
              onAddDrugTap: () => _showAddDrugSheet(context),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            PrescriptionNotesField(
              finalDiagnosis: state.finalDiagnosis,
              notes: state.notes,
              nextVisitDays: state.nextVisitDays,
              onFinalDiagnosisChanged: (value) {
                context.read<PrescriptionBloc>().add(
                      UpdatePrescriptionFieldsEvent(finalDiagnosis: value),
                    );
              },
              onNotesChanged: (value) {
                context.read<PrescriptionBloc>().add(
                      UpdatePrescriptionFieldsEvent(notes: value),
                    );
              },
              onNextVisitDaysChanged: (days) {
                context.read<PrescriptionBloc>().add(
                      UpdatePrescriptionFieldsEvent(
                        nextVisitDays: days,
                        clearNextVisitDays: days == null,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDrugSheet(BuildContext context) {
    final bloc = context.read<PrescriptionBloc>();
    AppBottomSheet.show(
      context: context,
      child: AddDrugSearchSheet(
        onDrugSelected: (drug) {
          bloc.add(AddDrugToPrescriptionEvent(drug));
        },
      ),
    );
  }
}
