// ────────────────────────────────────────────────────────
// شاشة المواعيد الرئيسية — تجمع التبويبات والقائمة وFAB
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../manager/appointments_bloc.dart';
import '../manager/appointments_event.dart';
import '../manager/appointments_state.dart';
import 'widgets/add_appointment_sheet.dart';
import 'widgets/appointment_dialogs.dart';
import 'widgets/appointments_list.dart';
import 'widgets/appointments_tab_bar.dart';
import '../../../settings/presentation/manager/settings_state.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late final AppointmentsBloc _bloc;
  String _clinicId = '';
  String _doctorId = '';
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AppointmentsBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLoadAppointments();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _tryLoadAppointments({String? forceClinicId, String? forceDoctorId}) {
    final settingsState = context.read<SettingsCubit>().state;
    final newClinicId = forceClinicId ?? settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final settingsDoctorId = forceDoctorId ?? settingsState.currentDoctorId;
    final currentUser = context.read<AuthCubit>().state.user!;

    String newDoctorId;
    if (currentUser.role == StaffRoles.doctor) {
      newDoctorId = currentUser.id;
    } else {
      newDoctorId = (settingsDoctorId != null && settingsDoctorId.isNotEmpty)
          ? settingsDoctorId
          : AppConstants.activeDoctorId;
    }

    final hasChanges = newClinicId != _clinicId || newDoctorId != _doctorId;
    if (_hasLoaded && !hasChanges) return;
    if (newClinicId.isEmpty) return;

    _clinicId = newClinicId;
    _doctorId = newDoctorId;
    _hasLoaded = true;

    _bloc.add(
      SubscribeAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().state.user!;

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id ||
            previous.currentDoctorId != current.currentDoctorId,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null) {
            _tryLoadAppointments(
              forceClinicId: settingsState.clinicEntity!.id,
              forceDoctorId: settingsState.currentDoctorId,
            );
          }
        },
        child: _AppointmentsBody(
          currentUser: currentUser,
          bloc: _bloc,
          clinicId: _clinicId,
          doctorId: _doctorId,
          hasLoaded: _hasLoaded,
        ),
      ),
    );
  }
}

class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody({
    required this.currentUser,
    required this.bloc,
    required this.clinicId,
    required this.doctorId,
    required this.hasLoaded,
  });

  final dynamic currentUser;
  final AppointmentsBloc bloc;
  final String clinicId;
  final String doctorId;
  final bool hasLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.appointments,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.queue_outlined, color: context.primary),
            tooltip: AppStrings.queueTooltip,
            onPressed: () => context.push(RouteConstants.waitingQueue),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        buildWhen: (previous, current) {
          return previous.runtimeType != current.runtimeType ||
              (previous is AppointmentsLoaded &&
                  current is AppointmentsLoaded &&
                  (previous.activeTab != current.activeTab ||
                      previous.statusFilter != current.statusFilter ||
                      previous.filteredAppointments != current.filteredAppointments));
        },
        builder: (context, state) {
          if (state is AppointmentsInitial || state is AppointmentsLoading) {
            return ResponsiveHelper.responsiveCenter(
              maxWidth: AppConstants.maxContentWidth,
              child: const Padding(
                padding: EdgeInsets.all(AppConstants.spaceMd),
                child: ShimmerList(itemCount: 6),
              ),
            );
          }
          if (state is AppointmentsError) {
            return AppErrorWidget.buildErrorView(
              context: context,
              error: state.message,
              onRetry: () => bloc.add(
                LoadAppointmentsEvent(doctorId: doctorId, clinicId: clinicId),
              ),
            );
          }
          if (state is AppointmentsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final settingsState = context.read<SettingsCubit>().state;
                final currentClinicId = settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
                final settingsDoctorId = settingsState.currentDoctorId;
                String currentDoctorId = currentUser.role == StaffRoles.doctor
                    ? currentUser.id
                    : ((settingsDoctorId != null && settingsDoctorId.isNotEmpty)
                        ? settingsDoctorId
                        : AppConstants.activeDoctorId);

                bloc.add(
                  LoadAppointmentsEvent(doctorId: currentDoctorId, clinicId: currentClinicId),
                );
                await Future.delayed(const Duration(milliseconds: 200));
              },
              child: ResponsiveHelper.responsiveCenter(
                maxWidth: AppConstants.maxContentWidth,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                  children: [
                    AppointmentsTabBar(
                      activeTab: state.activeTab,
                      onTabChanged: (tab) => bloc.add(ChangeAppointmentsTabEvent(tab)),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppointmentsList(
                      appointments: state.filteredAppointments,
                      statusFilter: state.statusFilter,
                      onFilterChanged: (filter) => bloc.add(ChangeStatusFilterEvent(filter)),
                      onItemTap: (item) => context.push('${RouteConstants.appointments}/${item.id}'),
                      onItemMore: (item) => AppointmentDialogs.showActions(
                        context: context,
                        item: item,
                        bloc: bloc,
                        clinicId: clinicId,
                        doctorId: doctorId,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddAppointmentSheet.show(context),
        backgroundColor: context.primary,
        foregroundColor: context.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.newAppointment),
      ),
    );
  }
}
