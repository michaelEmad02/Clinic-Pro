// ────────────────────────────────────────────────────────
// تبويب السجلات الطبية (الفحوصات والأشعات) في شاشة تفاصيل المريض
// يمنح تجاوباً ممتازاً لجميع الشاشات ودعماً للثيم والتنقل الأنيق
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/core/widgets/empty_state.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:clinic_pro/features/medical_records/presentation/manager/medical_records_state.dart';
import 'medical_record_card.dart';
import 'upload_medical_record_dialog.dart';

class MedicalRecordsTab extends StatelessWidget {
  final String patientId;
  final String clinicId;

  const MedicalRecordsTab({
    super.key,
    required this.patientId,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MedicalRecordsCubit>()..loadRecords(patientId),
      child: _MedicalRecordsView(patientId: patientId, clinicId: clinicId),
    );
  }
}

class _MedicalRecordsView extends StatelessWidget {
  final String patientId;
  final String clinicId;

  const _MedicalRecordsView({
    required this.patientId,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicalRecordsCubit, MedicalRecordsState>(
      listener: (context, state) {
        if (state is MedicalRecordsLoaded && state.operationMessage != null) {
          AppSnackbar.success(context, message: state.operationMessage!);
        }
        if (state is MedicalRecordsError) {
          AppSnackbar.error(context, message: state.message);
        }
      },
      builder: (context, state) {
        if (state is MedicalRecordsLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.spaceLg),
            child: ShimmerList(itemCount: 4),
          );
        }

        if (state is MedicalRecordsError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<MedicalRecordsCubit>().loadRecords(patientId),
          );
        }

        if (state is MedicalRecordsLoaded) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final isTablet = ResponsiveHelper.isTablet(context);
          final filtered = state.filteredRecords;
          final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
          final childAspectRatio = isMobile ? 0.78 : (isTablet ? 0.82 : 0.86);

          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'add_medical_record_fab',
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(
                AppStrings.attachRecord,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _openUploadDialog(context, state.selectedFilter),
            ),
            body: CustomScrollView(
              slivers: [
                // شريط التصفية العلوي
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _buildFilterBar(context, state),
                  ),
                ),

                // حالة الخلو من البيانات
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.medical_information_outlined,
                      title: AppStrings.noRecordsOrRadiology,
                      subtitle: state.selectedFilter == 'all'
                          ? AppStrings.noRecordsForPatientYet
                          : AppStrings.noMatchingRecords,
                    ),
                  )
                else
                  // شبكة الفحوصات الطبية المترابطة
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: childAspectRatio,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = filtered[index];
                          return MedicalRecordCard(
                            record: record,
                            onDelete: () {
                              context.read<MedicalRecordsCubit>().deleteRecord(
                                    recordId: record.id,
                                    storagePath: record.storagePath,
                                  );
                            },
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, MedicalRecordsLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: AppStrings.filterAllRecords(state.records.length),
            isSelected: state.selectedFilter == 'all',
            onTap: () => context.read<MedicalRecordsCubit>().setFilter('all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: AppStrings.filterLabTests(state.labTestsCount),
            isSelected: state.selectedFilter == MedicalRecordType.labTest,
            onTap: () => context
                .read<MedicalRecordsCubit>()
                .setFilter(MedicalRecordType.labTest),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: AppStrings.filterRadiology(state.radiologyCount),
            isSelected: state.selectedFilter == MedicalRecordType.radiology,
            onTap: () => context
                .read<MedicalRecordsCubit>()
                .setFilter(MedicalRecordType.radiology),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: AppStrings.filterLinked(state.linkedCount),
            isSelected: state.selectedFilter == 'linked',
            onTap: () =>
                context.read<MedicalRecordsCubit>().setFilter('linked'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: AppStrings.filterUnlinked(state.unlinkedCount),
            isSelected: state.selectedFilter == 'unlinked',
            onTap: () =>
                context.read<MedicalRecordsCubit>().setFilter('unlinked'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: AppTextStyles.caption(context).copyWith(
          color: isSelected ? Colors.white : context.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        selectedColor: context.primary,
        backgroundColor: context.surfaceColor,
        side: BorderSide(
          color: isSelected ? context.primary : context.borderColor,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  void _openUploadDialog(BuildContext context, String currentFilter) {
    final initialType = currentFilter == MedicalRecordType.radiology
        ? MedicalRecordType.radiology
        : MedicalRecordType.labTest;

    final cubit = context.read<MedicalRecordsCubit>();

    UploadMedicalRecordDialog.show(
      context,
      clinicId: clinicId,
      patientId: patientId,
      initialType: initialType,
      onUpload: ({
        required clinicId,
        required patientId,
        doctorId,
        appointmentId,
        prescriptionId,
        required type,
        required title,
        required imageFile,
        required recordDate,
        notes,
      }) {
        return cubit.uploadRecord(
          clinicId: clinicId,
          patientId: patientId,
          doctorId: doctorId,
          appointmentId: appointmentId,
          prescriptionId: prescriptionId,
          type: type,
          title: title,
          imageFile: imageFile,
          recordDate: recordDate,
          notes: notes,
        );
      },
    );
  }
}
