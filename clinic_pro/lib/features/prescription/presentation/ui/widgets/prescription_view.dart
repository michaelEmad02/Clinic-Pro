// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_bloc.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_event.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_state.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/add_drug_search_sheet.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/drugs_list_section.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_bottom_actions_bar.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_header_card.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_notes_field.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/templates_selector_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PrescriptionView extends StatelessWidget {
  const PrescriptionView(this.isEditing, {super.key});
  final bool isEditing;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrescriptionBloc, PrescriptionState>(
      // عند نجاح الحفظ، نعود للشاشة السابقة مع رسالة نجاح
      listener: (context, state) {
        if (state.status == PrescriptionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${AppStrings.prescription} ${AppStrings.success} ✓'),
              backgroundColor: context.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
          backgroundColor: context.background,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${AppStrings.print} ${AppStrings.loading}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onWhatsApp: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${AppStrings.save} ${AppStrings.loading}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
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
      backgroundColor: context.surface,
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
          // زر نسخ آخر روشتة
          TextButton.icon(
            onPressed: () {
              context.read<PrescriptionBloc>().add(
                    const CopyPreviousPrescriptionEvent(),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppStrings.prescription} ${AppStrings.success} ✓'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.content_copy, size: 18, color: context.primary),
            label: Text(
              AppStrings.copyLastPrescription,
              style: AppTextStyles.caption(context).copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: context.border, height: 1),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrescriptionState state) {
    // حالة التحميل الأولي
    if (state.status == PrescriptionStatus.initial ||
        state.status == PrescriptionStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.primary),
            const SizedBox(height: 16),
            Text(AppStrings.loading),
          ],
        ),
      );
    }

    // حالة الخطأ
    if (state.status == PrescriptionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.danger),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? AppStrings.loadFailed,
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(AppStrings.close),
            ),
          ],
        ),
      );
    }

    // المحتوى الرئيسي (حالة loaded أو success)
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // ١. بطاقة بيانات المريض
          PrescriptionHeaderCard(
            patientName: state.patientName,
            age: state.patientAge,
            gender: state.patientGender,
            bloodType: state.bloodType,
            visitType: state.visitType,
            doctorName: state.doctorName,
            visitDate: state.visitDate,
          ),

          const SizedBox(height: 8),
          // ٢. قسم قوالب الروشتات
          const TemplatesSelectorSection(),

          const SizedBox(height: 8),
          // ٣. قائمة الأدوية المختارة + زر إضافة
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

          const SizedBox(height: 8),
          // ٤. التشخيص النهائي والملاحظات
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
    );
  }

  /// فتح شاشة البحث عن الأدوية وإضافتها
  void _showAddDrugSheet(BuildContext context) {
    final bloc = context.read<PrescriptionBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddDrugSearchSheet(
            onDrugSelected: (drug) {
              bloc.add(AddDrugToPrescriptionEvent(drug));
            },
          ),
        ),
      ),
    );
  }
}
