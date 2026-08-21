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
import 'widgets/live_queue_section.dart';
import 'widgets/secretary_quick_actions.dart';
import 'widgets/daily_summary_row.dart';
import '../../../invoices/presentation/ui/invoices_screen.dart';


class SecretaryDashboardScreen extends StatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  State<SecretaryDashboardScreen> createState() => _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState extends State<SecretaryDashboardScreen> {
  int _currentIndex = 0;
  String _clinicId = '';
  String _secretaryId = '';
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

  void _tryLoadDashboard({BuildContext? customContext, String? forceClinicId}) {
    final activeContext = customContext ?? context;
    final settingsState = activeContext.read<SettingsCubit>().state;
    final newClinicId = forceClinicId ?? settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final currentUser = activeContext.read<AuthCubit>().state.user;

    if (currentUser == null || newClinicId.isEmpty) return;

    final newSecretaryId = currentUser.id;

    final hasChanges = newClinicId != _clinicId || newSecretaryId != _secretaryId;
    if (_hasLoaded && !hasChanges) return;

    _clinicId = newClinicId;
    _secretaryId = newSecretaryId;
    _hasLoaded = true;

    _cubit.loadDashboardData(
      secretaryId: _secretaryId,
      clinicId: _clinicId,
      secretaryName: currentUser.name,
      clinicName: settingsState.clinicEntity?.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديث البيانات تلقائياً عند الدخول أو إعادة بناء الواجهة
    _tryLoadDashboard();

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null) {
            _tryLoadDashboard(
              customContext: context,
              forceClinicId: settingsState.clinicEntity!.id,
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
              _tryLoadDashboard(customContext: context);
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
          String title = AppStrings.secretaryDashboardTitle;
          String sub = AppStrings.receptionOffice;
          if (state is SecretaryDashboardLoaded) {
            String str = AppStrings.isArabic ? 'الطبيب : ' : 'Doctor';
            title = state.clinicName;
            sub = '• ${AppStrings.welcomeBack}${state.secretaryName}         •  ${str + state.doctorName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
      actions: const [
        // IconButton(
        //   icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
        //   onPressed: () {},
        // ),
        // const SizedBox(width: 8),
        // Container(
        //   margin: const EdgeInsets.only(left: 16),
        //   width: 36,
        //   height: 36,
        //   decoration: const BoxDecoration(
        //     color: AppColors.primaryLight,
        //     shape: BoxShape.circle,
        //   ),
        //   child: const Center(
        //     child: Icon(
        //       Icons.support_agent,
        //       color: AppColors.primary,
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
    return BlocBuilder<SecretaryDashboardCubit, SecretaryDashboardState>(
      builder: (context, state) {
        if (state is SecretaryDashboardLoading) {
          return const Center(child: AppLoadingWidget());
        }
        if (state is SecretaryDashboardError) {
          return Center(child: Text(state.message));
        }
        if (state is SecretaryDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              _tryLoadDashboard(customContext: context);
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
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
                LiveQueueSection(
                  queue: state.liveQueue,
                  onCall: (appId) {
                    context.read<SecretaryDashboardCubit>().callPatient(appId);
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
