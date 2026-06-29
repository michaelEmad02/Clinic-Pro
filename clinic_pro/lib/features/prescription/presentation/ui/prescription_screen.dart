// ────────────────────────────────────────────────────────
// شاشة كشف المريض وكتابة الروشتة الطبية
// الشاشة الرئيسية التي تجمع كل الأقسام الفرعية:
// بطاقة المريض، التشخيص، الأدوية، الملاحظات، وأزرار الحفظ
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/prescription_bloc.dart';
import '../manager/prescription_event.dart';
import '../manager/prescription_state.dart';
import 'widgets/prescription_header_card.dart';
import 'widgets/diagnosis_chips_section.dart';
import 'widgets/drugs_list_section.dart';
import 'widgets/prescription_notes_field.dart';
import 'widgets/prescription_bottom_actions_bar.dart';
import 'widgets/add_drug_search_sheet.dart';

class PrescriptionScreen extends StatelessWidget {
  final String appointmentId;
  final bool isEditing;

  const PrescriptionScreen({
    super.key,
    required this.appointmentId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrescriptionBloc()
        ..add(LoadPrescriptionDataEvent(appointmentId)),
      child: const _PrescriptionView(),
    );
  }
}

class _PrescriptionView extends StatelessWidget {
  const _PrescriptionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrescriptionBloc, PrescriptionState>(
      // عند نجاح الحفظ، نعود للشاشة السابقة مع رسالة نجاح
      listener: (context, state) {
        if (state.status == PrescriptionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حفظ الروشتة وإنهاء الكشف بنجاح ✓'),
              backgroundColor: AppColors.accent,
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
              content: Text(state.errorMessage ?? 'حدث خطأ أثناء الحفظ'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, state),
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
                      const SnackBar(
                        content: Text('ميزة الطباعة قيد التطوير...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onWhatsApp: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ميزة الإرسال عبر واتساب قيد التطوير...'),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, PrescriptionState state) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كشف المريض',
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (state.status == PrescriptionStatus.loaded)
            Text(
              state.patientName,
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        // زر نسخ آخر روشتة
        TextButton.icon(
          onPressed: () {
            context.read<PrescriptionBloc>().add(
              const CopyPreviousPrescriptionEvent(),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم نسخ آخر روشتة متاحة ✓'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.content_copy, size: 18, color: AppColors.primary),
          label: Text(
            'نسخ آخر روشتة',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PrescriptionState state) {
    // حالة التحميل الأولي
    if (state.status == PrescriptionStatus.initial ||
        state.status == PrescriptionStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('جاري تحميل بيانات الكشف...'),
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
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'تعذر تحميل البيانات',
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('العودة'),
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
          // ٢. قسم التشخيص الطبي (اختيار رقاقات + إضافة مخصص)
          DiagnosisChipsSection(
            selectedDiagnosis: state.selectedDiagnosis,
            onToggleDiagnosis: (diagnosis) {
              context.read<PrescriptionBloc>().add(
                ToggleDiagnosisEvent(diagnosis),
              );
            },
            onAddCustomDiagnosis: (diagnosis) {
              context.read<PrescriptionBloc>().add(
                AddCustomDiagnosisEvent(diagnosis),
              );
            },
          ),

          const SizedBox(height: 8),
          // ٣. قائمة الأدوية المختارة + زر إضافة
          DrugsListSection(
            selectedDrugs: state.selectedDrugs,
            onUpdateDrug: (drugId, {doseOption, doseFrequency, doseDuration, doseTiming, isPrn}) {
              context.read<PrescriptionBloc>().add(
                UpdateDrugDoseEvent(
                  drugId: drugId,
                  doseOption: doseOption,
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
