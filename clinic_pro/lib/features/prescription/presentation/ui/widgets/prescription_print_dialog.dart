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
import 'package:clinic_pro/features/prescription/presentation/manager/prescription_pdf_state.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';

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
  String _pageFormat = 'A5'; // مقاس الورق A4 / A5 / A6 / custom
  final _widthController = TextEditingController(text: '15.0');
  final _heightController = TextEditingController(text: '20.0');

  double? get _customWidth => double.tryParse(_widthController.text);
  double? get _customHeight => double.tryParse(_heightController.text);



  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentDialog =
        context.findAncestorWidgetOfExactType<PrescriptionPrintDialog>();
    final prescription = parentDialog?.prescription;
    final patient = parentDialog?.patient;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth > 850 ? 800.0 : screenWidth * 0.95;
    final dialogHeight = screenHeight > 700 ? 650.0 : screenHeight * 0.9;

    return BlocListener<PrescriptionPdfCubit, PrescriptionPdfState>(
      listenWhen: (previous, current) =>
          previous.printingSettings != current.printingSettings &&
          current.printingSettings != null,
      listener: (context, state) {
        final settings = state.printingSettings!;
        setState(() {
          _pageFormat = settings.defaultPageFormat;
          _includeHeader = !settings.hideHeader;
        });
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
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

            // ─── مفاتيح التحكم بالترويسة ومقاس الورق (Responsive Column/Wrap) ───
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
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

                      // خيارات مقاس الورق
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Text(
                            'مقاس الورق: ',
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text('A4'),
                            selected: _pageFormat == 'A4',
                            onSelected: (selected) {
                              if (selected) setState(() => _pageFormat = 'A4');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('A5'),
                            selected: _pageFormat == 'A5',
                            onSelected: (selected) {
                              if (selected) setState(() => _pageFormat = 'A5');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('A6'),
                            selected: _pageFormat == 'A6',
                            onSelected: (selected) {
                              if (selected) setState(() => _pageFormat = 'A6');
                            },
                          ),
                          ChoiceChip(
                            label: const Text('تخصيص'),
                            selected: _pageFormat == 'custom',
                            onSelected: (selected) {
                              if (selected) setState(() => _pageFormat = 'custom');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_pageFormat == 'custom') ...[
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'العرض (سم):',
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 60,
                              height: 32,
                              child: TextField(
                                controller: _widthController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                onChanged: (val) {
                                  if (double.tryParse(val) != null) setState(() {});
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'الارتفاع (سم):',
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 60,
                              height: 32,
                              child: TextField(
                                controller: _heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                onChanged: (val) {
                                  if (double.tryParse(val) != null) setState(() {});
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                      if (currentDoctor == null && settingsCubit.state.userEntity?.role == StaffRoles.doctor) {
                        final u = settingsCubit.state.userEntity!;
                        currentDoctor = StaffEntity(
                          id: u.id,
                          clinicId: currentClinic?.id ?? '',
                          userId: u.id,
                          name: u.name,
                          email: u.email ?? '',
                          phone: u.phone,
                          specialty: u.specialty,
                          avatarUrl: u.imageUrl,
                          role: u.role,
                          isActive: u.isActive,
                          joinedAt: DateTime.now(),
                        );
                      }
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
                      prescription: prescription!,
                      clinic: currentClinic,
                      doctor: currentDoctor,
                      patient: patient,
                      includeHeader: _includeHeader,
                      pageFormat: _pageFormat,
                      customWidth: _customWidth,
                      customHeight: _customHeight,
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
    ),);
  }
}
