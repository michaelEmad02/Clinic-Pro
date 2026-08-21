// ────────────────────────────────────────────────────────
// شاشة المرضى الرئيسية — مطابقة لتصميم Stitch
// تستخدم PatientsCubit مع UseCases (Clean Architecture)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/features/appointments/presentation/ui/widgets/add_appointment_sheet.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patients_cubit.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patients_state.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../domain/entities/patient_entity.dart';
import 'widgets/add_edit_patient_sheet.dart';
import 'widgets/patient_action_sheet.dart';
import 'widgets/patients_list.dart';
import 'widgets/patients_search_bar.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  late final PatientsCubit _cubit;
  String _clinicId = '';
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PatientsCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLoadPatients();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _tryLoadPatients({String? forceClinicId}) {
    final settingsState = context.read<SettingsCubit>().state;
    final newClinicId = forceClinicId ??
        settingsState.clinicEntity?.id ??
        AppConstants.activeClinicId;

    final hasChanges = newClinicId != _clinicId;
    if (_hasLoaded && !hasChanges) return;
    if (newClinicId.isEmpty) return;

    _clinicId = newClinicId;
    _hasLoaded = true;

    _cubit.loadPatients(clinicId: _clinicId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null) {
            _tryLoadPatients(forceClinicId: settingsState.clinicEntity!.id);
          }
        },
        child: _PatientsBody(
          cubit: _cubit,
          clinicId: _clinicId,
          hasLoaded: _hasLoaded,
        ),
      ),
    );
  }
}

class _PatientsBody extends StatelessWidget {
  final PatientsCubit cubit;
  final String clinicId;
  final bool hasLoaded;

  const _PatientsBody({
    required this.cubit,
    required this.clinicId,
    required this.hasLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.patients,
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              AppStrings.isArabic
                  ? 'إدارة سجلات المرضى والبيانات الشخصية'
                  : 'Manage patient records and personal data',
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: ResponsiveHelper.responsiveCenter(
        maxWidth: 1100,
        child: BlocBuilder<PatientsCubit, PatientsState>(
          builder: (context, state) {
            if (state is PatientsLoading) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(itemCount: 6),
              );
            }
            if (state is PatientsError) {
              return AppErrorWidget.buildErrorView(
                context: context,
                error: state.message,
                onRetry: () => cubit.loadPatients(clinicId: clinicId),
              );
            }
            if (state is PatientsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  final settingsState = context.read<SettingsCubit>().state;
                  final currentClinicId = settingsState.clinicEntity?.id ??
                      AppConstants.activeClinicId;
                  cubit.loadPatients(clinicId: currentClinicId);
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    PatientsSearchBar(
                      onChanged: (q) => cubit.search(q),
                    ),
                    const SizedBox(height: 16),
                    PatientsList(
                      patients: state.filteredPatients,
                      onItemTap: (patient) => context
                          .push('${RouteConstants.patients}/${patient.id}'),
                      onItemMore: (patient) => _showActions(context, patient),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditPatientSheet.show(context),
        backgroundColor: context.primary,
        foregroundColor: context.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addPatient),
      ),
    );
  }

  void _showActions(BuildContext context, PatientEntity patient) {
    PatientActionSheet.show(
      context: context,
      patient: patient,
      onViewDetails: () =>
          context.push('${RouteConstants.patients}/${patient.id}'),
      onEdit: () => AddEditPatientSheet.show(context, patient: patient),
      onBookAppointment: () {
        AddAppointmentSheet.show(
          context,
          initialPatientId: patient.id,
        );
      },
      onDeletePatient: () => _confirmDelete(context, patient),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, PatientEntity patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deletePatient),
        content: Text(
          AppStrings.isArabic
              ? 'هل أنت متأكد من حذف "${patient.name}"؟'
              : 'Are you sure you want to delete "${patient.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: context.danger),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.deletePatient(patient.id);
    }
  }
}
