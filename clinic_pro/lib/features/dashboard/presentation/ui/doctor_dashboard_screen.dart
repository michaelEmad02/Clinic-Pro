import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/widgets/app_responsive_scaffold.dart';
import '../../../appointments/presentation/manager/appointments_repository.dart';
import '../../../appointments/presentation/ui/appointments_screen.dart';
import '../../../patients/presentation/ui/patients_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../manager/doctor_dashboard_cubit.dart';
import '../manager/doctor_dashboard_state.dart';
import 'widgets/current_patient_card.dart';
import 'widgets/waiting_queue_list.dart';
import 'widgets/doctor_stats_row.dart';
import 'widgets/doctor_quick_actions.dart';
import '../../../expenses/presentation/ui/expenses_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorDashboardCubit(
        sl<AppointmentsRepository>(),
        sl<ICloudService>(),
      )..loadDashboardData(),
      child: AppResponsiveScaffold(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            context.read<DoctorDashboardCubit>().loadDashboardData();
          }
        },
        destinations: [
          NavigationRailDestination(
            icon: const Icon(TablerIcons.smart_home),
            label: Text(AppStrings.home),
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
            icon: const Icon(TablerIcons.wallet),
            label: Text(AppStrings.expenses),
          ),
          NavigationRailDestination(
            icon: const Icon(TablerIcons.settings),
            label: Text(AppStrings.settings),
          ),
        ],
        appBar: _currentIndex == 0 ? _buildAppBar(context) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildMainDashboardTab(),
            const AppointmentsScreen(),
            const PatientsScreen(),
            const ExpensesScreen(),
            const SettingsScreen(showBottomNav: false),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(context),
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
      actions: const [
        // IconButton(
        //   icon: Icon(Icons.notifications_none_outlined,
        //       color: context.textSecondary),
        //   onPressed: () {},
        // ),
        // const SizedBox(width: 8),
        // Container(
        //   margin: const EdgeInsets.only(left: 16),
        //   width: 36,
        //   height: 36,
        //   decoration: BoxDecoration(
        //     color: context.primaryLightColor,
        //     shape: BoxShape.circle,
        //   ),
        //   child: Center(
        //     child: Icon(
        //       Icons.healing_outlined,
        //       color: context.primary,
        //       size: 20,
        //     ),
        //   ),
        // ),
      ],
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
        if (state is DoctorDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DoctorDashboardError) {
          return Center(child: Text(state.message));
        }
        if (state is DoctorDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DoctorDashboardCubit>().loadDashboardData();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                DoctorStatsRow(
                  completedCount: state.completedCount,
                  waitingCount: state.waitingCount,
                  avgWaitingTime: state.avgWaitingTime,
                ),
                const SizedBox(height: 24),
                const DoctorQuickActions(),
                const SizedBox(height: 24),
                CurrentPatientCard(
                  patient: state.currentPatient,
                  onStartExamination: () async {
                    if (state.currentPatient != null) {
                      await context
                          .push('/prescription/${state.currentPatient!.id}');
                      if (context.mounted) {
                        context
                            .read<DoctorDashboardCubit>()
                            .loadDashboardData(autoCallNext: true);
                      }
                    }
                  },
                ),
                const SizedBox(height: 24),
                WaitingQueueList(
                  queue: state.waitingQueue,
                  onCallNext: () {
                    context.read<DoctorDashboardCubit>().callNextPatient();
                  },
                ),
              ],
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
        'label': AppStrings.expenses,
        'icon': TablerIcons.wallet,
        'activeIcon': TablerIcons.wallet
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
                  context.read<DoctorDashboardCubit>().loadDashboardData();
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
