// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../appointments/domain/entities/appointment_entity.dart';
import '../../../../appointments/presentation/manager/appointments_bloc.dart';
import '../../../../appointments/presentation/manager/appointments_event.dart';

class PrescriptionView extends StatelessWidget {
  const PrescriptionView(this.isEditing, {super.key, required this.appointment});
  final bool isEditing;
  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrescriptionBloc, PrescriptionState>(
      listener: (context, state) {
        if (state.status == PrescriptionStatus.success) {
          context.read<AppointmentsBloc>().add(
            CompleteAppointmentEvent(
              appointmentId: appointment.id,
              calledAt: appointment.calledAt,
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.prescription} ${AppStrings.success} ✓'),
              backgroundColor: context.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
            ),
          );
          context.pop();
        }
        if (state.status == PrescriptionStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppStrings.error),
              backgroundColor: context.danger,
              behavior: SnackBarBehavior.floating,
            ),
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
                  onSave: () {
                    context.read<PrescriptionBloc>().add(
                          const SavePrescriptionEvent(),
                        );
                  },
                  onPrint: () {
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

                    final prescEntity = PrescriptionEntity(
                      id: state.prescriptionId,
                      createdAt: DateTime.now().toIso8601String(),
                      clinicId: appointment.clinicId,
                      doctorId: appointment.doctorId,
                      patientId: appointment.patientId,
                      appointmentId: appointment.id,
                      diagnosis: state.selectedDiagnosis.join(', '),
                      notes: state.notes,
                      items: itemsMapped,
                    );

                    PrescriptionPrintDialog.show(
                      context,
                      prescription: prescEntity,
                    );
                  },
                  onWhatsApp: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppStrings.save} ${AppStrings.loading}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onFinishWithoutSaving: () {
                    context.read<AppointmentsBloc>().add(
                          CompleteAppointmentEvent(appointmentId: appointment.id),
                        );
                    context.pop();
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppStrings.prescription} ${AppStrings.success} ✓'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.content_copy, size: AppConstants.iconSizeLg, color: context.primary),
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
