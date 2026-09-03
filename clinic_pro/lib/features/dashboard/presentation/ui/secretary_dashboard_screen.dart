// ─────────────────────────────────────────
// هذا الملف يحتوي على واجهة لوحة تحكم السكرتير الرئيسية
// يعرض إحصائيات الاستقبال، قائمة الانتظار المباشرة، والإجراءات السريعة
// ─────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/patients/presentation/ui/patients_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_state.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/widgets/app_responsive_scaffold.dart';
import '../../../../core/widgets/lazy_indexed_stack.dart';
import '../../../appointments/presentation/ui/appointments_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../manager/secretary_dashboard_cubit.dart';
import '../manager/secretary_dashboard_state.dart';
import '../../../appointments/presentation/ui/widgets/waiting_queue_list.dart';
import 'widgets/secretary_quick_actions.dart';
import 'widgets/daily_summary_row.dart';
import '../../../invoices/presentation/ui/invoices_screen.dart';
import '../../../../core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/read_only_mode_banner.dart';


class SecretaryDashboardScreen extends StatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  State<SecretaryDashboardScreen> createState() => _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState extends State<SecretaryDashboardScreen> {
  int _currentIndex = 0;
  String _clinicId = '';
  String _secretaryId = '';
  String _doctorId = '';
  bool _hasLoaded = false;
  late final SecretaryDashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<SecretaryDashboardCubit>();
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

    final newSecretaryId = currentUser.id;
    final newDoctorId = settingsState.currentDoctorId ?? AppConstants.activeDoctorId;

    final hasChanges = newClinicId != _clinicId || newSecretaryId != _secretaryId || newDoctorId != _doctorId;
    if (_hasLoaded && !hasChanges && !forceRefresh) return;

    _clinicId = newClinicId;
    _secretaryId = newSecretaryId;
    _doctorId = newDoctorId;
    _hasLoaded = true;

    _cubit.loadDashboardData(
      secretaryId: _secretaryId,
      clinicId: _clinicId,
      secretaryName: currentUser.name,
      clinicName: settingsState.clinicEntity?.name,
      showLoading: hasChanges,
    );
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
            (previous.clinicEntity?.id != current.clinicEntity?.id && current.clinicEntity?.id != null) ||
            (previous.currentDoctorId != current.currentDoctorId && current.currentDoctorId != null),
        listener: (context, settingsState) {
          if (settingsState.clinicEntity?.id == null) return;
          _clinicId = '';
          _doctorId = '';
          _tryLoadDashboard(
            customContext: context,
            forceClinicId: settingsState.clinicEntity?.id,
            forceRefresh: true,
          );
        },
        child: AppResponsiveScaffold(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              _tryLoadDashboard(customContext: context, forceRefresh: true);
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
              icon: const Icon(TablerIcons.receipt_2),
              label: Text(AppStrings.invoices),
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
              const AppointmentsScreen(),
              const InvoicesScreen(),
              const PatientsScreen(),
              const SettingsScreen(role: StaffRoles.secretary, showBottomNav: false),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(customContext: context),
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
      title: BlocBuilder<SecretaryDashboardCubit, SecretaryDashboardState>(
        builder: (context, state) {
          String clinicName = AppStrings.isArabic
              ? 'عيادتك المتكاملة'
              : 'Your Integrated Clinic';
          String sub = AppStrings.secretaryDashboardTitle;
          if (state is SecretaryDashboardLoaded) {
            clinicName = state.clinicName;
            sub =
                '${state.doctorName.isNotEmpty ? state.doctorName : AppStrings.welcomeBack} • ${state.secretaryName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinicName,
                style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Text(
                sub,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
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
    return BlocBuilder<SecretaryDashboardCubit, SecretaryDashboardState>(
      builder: (context, state) {
        if (state is SecretaryDashboardLoading || state is SecretaryDashboardInitial) {
          return const Center(child: AppLoadingWidget());
        }
        if (state is SecretaryDashboardError) {
          return AppErrorWidget.buildErrorView(
            context: context,
            error: state.message,
            onRetry: () => _tryLoadDashboard(forceRefresh: true),
          );
        }
        if (state is SecretaryDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              _tryLoadDashboard(customContext: context);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                const ReadOnlyModeBanner(),
                DailySummaryRow(
                  todayAppointmentsCount: state.todayAppointmentsCount,
                  completedCount: state.completedCount,
                  waitingCount: state.waitingCount,
                  avgWaitingTime: state.avgWaitingTime,
                ),
                const SizedBox(height: 24),
                SecretaryQuickActions(
                  onTabChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 24),
                WaitingQueueList(
                  queue: state.liveQueue,
                  maxItems: 5,
                  onCallNext: () {
                    context.read<SecretaryDashboardCubit>().callNextPatient();
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

  Widget _buildBottomNav({required BuildContext customContext}) {
    final tabs = [
      {'label': AppStrings.home, 'icon': TablerIcons.smart_home, 'activeIcon': TablerIcons.smart_home},
      {'label': AppStrings.appointments, 'icon': TablerIcons.calendar, 'activeIcon': TablerIcons.calendar},
      {'label': AppStrings.invoices, 'icon': TablerIcons.receipt, 'activeIcon': TablerIcons.receipt},
      {'label': AppStrings.patients, 'icon': TablerIcons.users, 'activeIcon': TablerIcons.users},
      {'label': AppStrings.settings, 'icon': TablerIcons.settings, 'activeIcon': TablerIcons.settings},
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
                  _tryLoadDashboard(customContext: customContext);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 68,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? context.primaryLightColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isSelected ? (tab['activeIcon'] as IconData) : (tab['icon'] as IconData),
                        color: isSelected ? context.primary : context.textSecondary,
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
                        color: isSelected ? context.primary : context.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
