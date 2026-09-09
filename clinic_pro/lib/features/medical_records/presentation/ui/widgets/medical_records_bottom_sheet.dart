// ────────────────────────────────────────────────────────
// شيت استعراض وإرفاق الفحوصات الطبية في شاشة الروشتة (MedicalRecordsBottomSheet)
// يدعم التكيف الذكي بين الهواتف المحمولة والدسكتوب مع التوافق التام مع الثيم واللغة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
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

class MedicalRecordsBottomSheet extends StatelessWidget {
  final String patientId;
  final String clinicId;
  final String? doctorId;
  final String? appointmentId;
  final String? prescriptionId;

  const MedicalRecordsBottomSheet({
    super.key,
    required this.patientId,
    required this.clinicId,
    this.doctorId,
    this.appointmentId,
    this.prescriptionId,
  });

  /// عرض النافذة متكيفة كـ Sheet للموبايل وكـ Dialog للدسكتوب
  static Future<void> show(
    BuildContext context, {
    required String patientId,
    required String clinicId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MedicalRecordsBottomSheet(
          patientId: patientId,
          clinicId: clinicId,
          doctorId: doctorId,
          appointmentId: appointmentId,
          prescriptionId: prescriptionId,
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
            child: MedicalRecordsBottomSheet(
              patientId: patientId,
              clinicId: clinicId,
              doctorId: doctorId,
              appointmentId: appointmentId,
              prescriptionId: prescriptionId,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MedicalRecordsCubit>()..loadRecords(patientId),
      child: _MedicalRecordsBottomSheetContent(
        patientId: patientId,
        clinicId: clinicId,
        doctorId: doctorId,
        appointmentId: appointmentId,
        prescriptionId: prescriptionId,
      ),
    );
  }
}

class _MedicalRecordsBottomSheetContent extends StatelessWidget {
  final String patientId;
  final String clinicId;
  final String? doctorId;
  final String? appointmentId;
  final String? prescriptionId;

  const _MedicalRecordsBottomSheetContent({
    required this.patientId,
    required this.clinicId,
    this.doctorId,
    this.appointmentId,
    this.prescriptionId,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      height: isMobile ? MediaQuery.of(context).size.height * 0.85 : double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // مقبض السحب للموبايل
          if (isMobile)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // ترويسة الشيت
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medical_services_rounded,
                      color: context.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.patientMedicalRecords,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openUpload(context),
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: Text(AppStrings.attachRecord),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // المحتوى
          Expanded(
            child: BlocConsumer<MedicalRecordsCubit, MedicalRecordsState>(
              listener: (context, state) {
                if (state is MedicalRecordsLoaded &&
                    state.operationMessage != null) {
                  AppSnackbar.success(context,
                      message: state.operationMessage!);
                }
              },
              builder: (context, state) {
                if (state is MedicalRecordsLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(AppConstants.spaceLg),
                    child: ShimmerList(itemCount: 3),
                  );
                }

                if (state is MedicalRecordsError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<MedicalRecordsCubit>()
                        .loadRecords(patientId),
                  );
                }

                if (state is MedicalRecordsLoaded) {
                  if (state.records.isEmpty) {
                    return EmptyState(
                      icon: Icons.medical_information_outlined,
                      title: AppStrings.noRecordsYet,
                      subtitle: AppStrings.noRecordsSubtitle,
                    );
                  }

                  final crossAxisCount = isMobile ? 2 : 3;

                  return GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: isMobile ? 0.78 : 0.82,
                    ),
                    itemCount: state.records.length,
                    itemBuilder: (context, index) {
                      final record = state.records[index];
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
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openUpload(BuildContext context) {
    final cubit = context.read<MedicalRecordsCubit>();

    UploadMedicalRecordDialog.show(
      context,
      clinicId: clinicId,
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      prescriptionId: prescriptionId,
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
