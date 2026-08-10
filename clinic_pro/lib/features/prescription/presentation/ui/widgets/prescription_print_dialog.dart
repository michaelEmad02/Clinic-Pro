// ────────────────────────────────────────────────────────
// حوار معاينة وتصدير الطباعة التفاعلي للروشتة الطبية
// يتيح المعاينة الفورية، اختيار مقاس الورق (A4 / A5)،
// والتحويل بين طباعة الترويسة الكاملة أو الطباعة على ورق مروّس جاهز
// عبر الاستعانة بـ PrescriptionPdfCubit وفقاً لقواعد Clean Architecture
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_pdf_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PrescriptionPrintDialog extends StatelessWidget {
  final PrescriptionEntity prescription;
  final PatientEntity? patient;

  const PrescriptionPrintDialog({
    super.key,
    required this.prescription,
    this.patient,
  });

  static Future<void> show(
    BuildContext context, {
    required PrescriptionEntity prescription,
    PatientEntity? patient,
  }) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider<PrescriptionPdfCubit>(
        create: (_) => sl<PrescriptionPdfCubit>(),
        child: PrescriptionPrintDialog(
          prescription: prescription,
          patient: patient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _PrescriptionPrintDialogContent();
  }
}

class _PrescriptionPrintDialogContent extends StatefulWidget {
  const _PrescriptionPrintDialogContent();

  @override
  State<_PrescriptionPrintDialogContent> createState() =>
      __PrescriptionPrintDialogContentState();
}

class __PrescriptionPrintDialogContentState
    extends State<_PrescriptionPrintDialogContent> {
  bool _includeHeader = true; // طباعة الترويسة أم الاعتماد على ورق مروّس جاهز
  bool _isA5Format = false; // مقاس الورق A5 أم A4

  @override
  Widget build(BuildContext context) {
    final parentDialog =
        context.findAncestorWidgetOfExactType<PrescriptionPrintDialog>();
    final prescription = parentDialog?.prescription;
    final patient = parentDialog?.patient;

    if (prescription == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800,
        height: 650,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── شريط التحكم والخيارات ───
            Row(
              children: [
                Icon(Icons.print_outlined, color: context.primary),
                const SizedBox(width: 8),
                Text(
                  'معاينة وطباعة الروشتة',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // ─── مفاتيح التحكم بالترويسة ومقاس الورق (Responsive Wrap) ───
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  // مفتاح تفعيل/إلغاء الترويسة للورق المروّس الجاهز
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: _includeHeader,
                        activeColor: context.primary,
                        onChanged: (val) {
                          setState(() {
                            _includeHeader = val;
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          _includeHeader
                              ? 'طباعة الترويسة والشعار'
                              : 'ورق مروّس جاهز',
                          style: AppTextStyles.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // خيار مقاس الورق A5 / A4
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'مقاس الورق: ',
                        style: AppTextStyles.caption(context),
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('A5'),
                        selected: _isA5Format,
                        onSelected: (selected) {
                          if (selected) setState(() => _isA5Format = true);
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('A4'),
                        selected: !_isA5Format,
                        onSelected: (selected) {
                          if (selected) setState(() => _isA5Format = false);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── شاشة المعاينة الطباعية التفاعلية عبر PrescriptionPdfCubit ───
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfPreview(
                  build: (format) async {
                    ClinicEntity? currentClinic;
                    StaffEntity? currentDoctor;
                    try {
                      final settingsCubit = context.read<SettingsCubit>();
                      currentClinic = settingsCubit.state.clinicEntity;
                      currentDoctor = settingsCubit.state.doctor;
                    } catch (_) {}

                    // إذا لم تكن هناك بيانات لـ currentDoctor (مثلاً الطبيب هو المستخدم نفسه ولم تتم تعبئة SettingsCubit بعد)
                    if (currentDoctor == null) {
                      try {
                        final authCubit = context.read<AuthCubit>();
                        final currentUser = authCubit.state.user;
                        if (currentUser != null) {
                          currentDoctor = StaffEntity(
                            id: currentUser.id,
                            clinicId: currentClinic?.id ?? '',
                            userId: currentUser.id,
                            name: currentUser.name,
                            email: currentUser.email ?? '',
                            phone: currentUser.phone,
                            specialty: currentUser.specialty,
                            avatarUrl: currentUser.imageUrl,
                            role: currentUser.role,
                            isActive: currentUser.isActive,
                            joinedAt: DateTime.now(),
                          );
                        }
                      } catch (_) {}
                    }

                    final pdfCubit = context.read<PrescriptionPdfCubit>();
                    return await pdfCubit.generatePdf(
                      prescription: prescription,
                      clinic: currentClinic,
                      doctor: currentDoctor,
                      patient: patient,
                      includeHeader: _includeHeader,
                      isA5Format: _isA5Format,
                    );
                  },
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  previewPageMargin: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
