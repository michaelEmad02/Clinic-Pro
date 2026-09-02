import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/widgets/app_responsive_scaffold.dart';
import 'package:clinic_pro/core/widgets/lazy_indexed_stack.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_state.dart';
import '../../../appointments/presentation/ui/appointments_screen.dart';
import '../../../patients/presentation/ui/patients_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../manager/doctor_dashboard_cubit.dart';
import '../manager/doctor_dashboard_state.dart';
import '../../../appointments/presentation/ui/widgets/current_patient_card.dart';
import '../../../appointments/presentation/ui/widgets/waiting_queue_list.dart';
import 'widgets/doctor_stats_row.dart';
import 'widgets/doctor_quick_actions.dart';
import 'widgets/doctor_dashboard_shimmer.dart';
import '../../../appointments/presentation/ui/waiting_queue_screen.dart';
import '../../../../core/widgets/app_error_widget.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;
  String _clinicId = '';
  String _doctorId = '';
  bool _hasLoaded = false;
  late final DoctorDashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DoctorDashboardCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLoadDashboard();
  }

  void _tryLoadDashboard({bool forceRefresh = false, BuildContext? customContext, String? forceClinicId}) {
    final activeContext = customContext ?? context;
    final settingsState = activeContext.read<SettingsCubit>().state;
    final newClinicId = forceClinicId ?? settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final currentUser = activeContext.read<AuthCubit>().state.user;

    if (currentUser == null || newClinicId.isEmpty) return;

    final newDoctorId = currentUser.id;

    final hasChanges = newClinicId != _clinicId || newDoctorId != _doctorId;
    if (_hasLoaded && !hasChanges && !forceRefresh) return;

    _clinicId = newClinicId;
    _doctorId = newDoctorId;
    _hasLoaded = true;

    _cubit.loadDashboardData(
      doctorId: _doctorId,
      clinicId: _clinicId,
      doctorName: currentUser.name,
      clinicName: settingsState.clinicEntity?.name,
      //autoCallNext: autoCallNext,
      showLoading: hasChanges,
    );//
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoaded) {
      _tryLoadDashboard();
    }

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id &&
            current.clinicEntity?.id != null,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null) {
            _clinicId = '';
            _tryLoadDashboard(
              customContext: context,
              forceClinicId: settingsState.clinicEntity!.id,
              forceRefresh: true,
            );
          }
        },
        child: AppResponsiveScaffold(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
            // _tryLoadDashboard(customContext: context);
              _tryLoadDashboard(customContext: context, forceRefresh: true);
            }
          },
          destinations: [
            NavigationRailDestination(
              icon: const Icon(TablerIcons.smart_home),
              label: Text(AppStrings.home),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.clock),
              label: Text(AppStrings.queueTooltip),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.calendar),
              label: Text(AppStrings.appointments),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.users),
              label: Text(AppStrings.patients),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.settings),
              label: Text(AppStrings.settings),
            ),
          ],
          appBar: _currentIndex == 0 ? _buildAppBar(context) : null,
          body: LazyIndexedStack(
            index: _currentIndex,
            children: [
              _buildMainDashboardTab(),
              const WaitingQueueScreen(),
              const AppointmentsScreen(),
              const PatientsScreen(),
              const SettingsScreen(showBottomNav: false),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
        builder: (context, state) {
          String clinicName = AppStrings.isArabic
              ? 'عيادتك المتكاملة'
              : 'Your Integrated Clinic';
          String doctorName =
              '${AppStrings.welcomeBack}${AppStrings.isArabic ? 'دكتور' : 'Doctor'}';
          if (state is DoctorDashboardLoaded) {
            clinicName = state.clinicName;
            doctorName = '${AppStrings.welcomeBack}${state.doctorName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  clinicName,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              Center(
                child: Text(
                  doctorName,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.borderColor,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMainDashboardTab() {
    return BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
      builder: (context, state) {
        if (state is DoctorDashboardLoading || state is DoctorDashboardInitial) {
          return const DoctorDashboardShimmer();
        }
        if (state is DoctorDashboardError) {
          return AppErrorWidget.buildErrorView(
            context: context,
            error: state.message,
            onRetry: () => _tryLoadDashboard(forceRefresh: true),
          );
        }
        if (state is DoctorDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              _tryLoadDashboard(customContext: context);
            },
            child: ResponsiveHelper.responsiveCenter(
              maxWidth: 1100,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  DoctorStatsRow(
                    todayAppointmentsCount: state.todayAppointmentsCount,
                    completedCount: state.completedCount,
                    waitingCount: state.waitingCount,
                    avgWaitingTime: state.avgWaitingTime,
                    todayRevenue: state.todayRevenue,
                    collectedAmount: state.collectedAmount,
                  ),
                  const SizedBox(height: 24),
                  const DoctorQuickActions(),
                  const SizedBox(height: 24),
                  CurrentPatientCard(
                    patient: state.currentPatient,
                    onStartExamination: () async {
                      if (state.currentPatient != null) {
                        await context.push(
                          '/prescription/${state.currentPatient!.id}',
                          extra: state.currentPatient,
                        );
                        if (context.mounted) {
                        //     _tryLoadDashboard(autoCallNext: true, customContext: context);
                          _tryLoadDashboard(forceRefresh: true, customContext: context);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  WaitingQueueList(
                    queue: state.waitingQueue,
                    maxItems: 5,
                    onCallNext: () {
                      context.read<DoctorDashboardCubit>().callNextPatient();
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final tabs = [
      {
        'label': AppStrings.home,
        'icon': TablerIcons.smart_home,
        'activeIcon': TablerIcons.smart_home
      },
      {
        'label': AppStrings.queueTooltip,
        'icon': TablerIcons.clock,
        'activeIcon': TablerIcons.clock
      },
      {
        'label': AppStrings.appointments,
        'icon': TablerIcons.calendar,
        'activeIcon': TablerIcons.calendar
      },
      {
        'label': AppStrings.patients,
        'icon': TablerIcons.users,
        'activeIcon': TablerIcons.users
      },
      {
        'label': AppStrings.settings,
        'icon': TablerIcons.settings,
        'activeIcon': TablerIcons.settings
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final isSelected = _currentIndex == index;
            final tab = tabs[index];

            return InkWell(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 0) {
                  _tryLoadDashboard(customContext: context);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 76,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.primaryLightColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isSelected
                            ? (tab['activeIcon'] as IconData)
                            : (tab['icon'] as IconData),
                        color: isSelected
                            ? context.primary
                            : context.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: isSelected
                            ? context.primary
                            : context.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
