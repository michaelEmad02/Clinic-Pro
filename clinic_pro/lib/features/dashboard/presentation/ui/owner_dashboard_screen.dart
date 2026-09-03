import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/widgets/app_responsive_scaffold.dart';
import 'package:clinic_pro/core/widgets/lazy_indexed_stack.dart';
import '../../../clinics/presentation/ui/clinics_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../../../settings/presentation/manager/settings_cubit.dart';
import '../../../settings/presentation/manager/settings_state.dart';
import '../manager/owner_summary_stats_cubit.dart';
import '../manager/owner_summary_stats_state.dart';
import '../manager/owner_weekly_revenue_cubit.dart';
import '../manager/owner_weekly_revenue_state.dart';
import '../manager/owner_alerts_cubit.dart';
import '../manager/owner_alerts_state.dart';
import 'widgets/dashboard_summary_row.dart';
import 'widgets/dashboard_shimmers.dart';
import 'widgets/alerts_section.dart';
import 'widgets/revenue_bar_chart.dart';
import 'widgets/quick_actions_row.dart';
import '../../../reports/presentation/ui/reports_screen.dart';
import '../../../expenses/presentation/ui/expenses_screen.dart';
import 'package:clinic_pro/core/widgets/read_only_mode_banner.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final ownerId = authState.user?.id ?? '';
    final ownerName = authState.user?.name ?? AppStrings.ownerRoleLabel;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<OwnerSummaryStatsCubit>()..loadSummaryStats(ownerId),
        ),
        BlocProvider(
          create: (_) => sl<OwnerWeeklyRevenueCubit>()..loadWeeklyRevenue(ownerId),
        ),
        BlocProvider(
          create: (_) => sl<OwnerAlertsCubit>()..loadAlerts(ownerId),
        ),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.clinicEntity?.id != current.clinicEntity?.id &&
            current.clinicEntity?.id != null,
        listener: (context, settingsState) {
          if (settingsState.clinicEntity != null && ownerId.isNotEmpty) {
            _refreshAll(context, ownerId, forceRefresh: true);
          }
        },
        child: AppResponsiveScaffold(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationRailDestination(
              icon: const Icon(TablerIcons.smart_home),
              label: Text(AppStrings.home),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.building_hospital),
              label: Text(AppStrings.clinics),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.wallet),
              label: Text(AppStrings.expenses),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.chart_bar),
              label: Text(AppStrings.reports),
            ),
            NavigationRailDestination(
              icon: const Icon(TablerIcons.settings),
              label: Text(AppStrings.settings),
            ),
          ],
          appBar: _currentIndex == 0 ? _buildAppBar(context, ownerName) : null,
          body: LazyIndexedStack(
            index: _currentIndex,
            children: [
              _buildMainDashboardTab(ownerId),
              const ClinicsScreen(),
              const ExpensesScreen(),
              const ReportsScreen(),
              const SettingsScreen(
                role: StaffRoles.owner,
                showBottomNav: false,
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  void _refreshAll(BuildContext context, String ownerId, {bool forceRefresh = false}) {
    context.read<OwnerSummaryStatsCubit>().loadSummaryStats(ownerId, forceRefresh: forceRefresh);
    context.read<OwnerWeeklyRevenueCubit>().loadWeeklyRevenue(ownerId, forceRefresh: forceRefresh);
    context.read<OwnerAlertsCubit>().loadAlerts(ownerId, forceRefresh: forceRefresh);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String ownerName) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.isArabic ? 'كلينك برو' : 'Clinic Pro',
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          Text(
            '${AppStrings.welcomeBack}$ownerName',
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
      actions: const [],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.border,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMainDashboardTab(String ownerId) {
    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: () async {
            _refreshAll(context, ownerId, forceRefresh: true);
          },
          child: ResponsiveHelper.responsiveCenter(
            maxWidth: 1100,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                const ReadOnlyModeBanner(),
                _buildAlertsSection(),
                _buildSummaryStatsSection(),
                const SizedBox(height: 24),
                const QuickActionsRow(),
                const SizedBox(height: 24),
                _buildWeeklyRevenueSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStatsSection() {
    return BlocBuilder<OwnerSummaryStatsCubit, OwnerSummaryStatsState>(
      builder: (context, state) {
        if (state is OwnerSummaryStatsLoading) {
          return const DashboardSummaryShimmer();
        }
        if (state is OwnerSummaryStatsLoaded) {
          return DashboardSummaryRow(
            todayNetRevenue: state.stats.todayNetRevenue,
            totalPatients: state.stats.totalPatients,
            todayAppointments: state.stats.todayAppointments,
            todayCompletedAppointments: state.stats.todayCompletedAppointments,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAlertsSection() {
    return BlocBuilder<OwnerAlertsCubit, OwnerAlertsState>(
      builder: (context, state) {
        if (state is OwnerAlertsLoading) {
          return const AlertsSectionShimmer();
        }
        if (state is OwnerAlertsLoaded && state.alerts.isNotEmpty) {
          return Column(
            children: [
              const SizedBox(height: 0),
              AlertsSection(alerts: state.alerts),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWeeklyRevenueSection() {
    return BlocBuilder<OwnerWeeklyRevenueCubit, OwnerWeeklyRevenueState>(
      builder: (context, state) {
        if (state is OwnerWeeklyRevenueLoading) {
          return const WeeklyRevenueChartShimmer();
        }
        if (state is OwnerWeeklyRevenueLoaded) {
          return RevenueBarChart(weeklyRevenue: state.weeklyRevenue);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      {
        'label': AppStrings.home,
        'icon': TablerIcons.smart_home,
        'activeIcon': TablerIcons.smart_home
      },
      {
        'label': AppStrings.clinics,
        'icon': TablerIcons.building_hospital,
        'activeIcon': TablerIcons.building_hospital
      },
      {
        'label': AppStrings.expenses,
        'icon': TablerIcons.wallet,
        'activeIcon': TablerIcons.wallet
      },
      {
        'label': AppStrings.reports,
        'icon': TablerIcons.chart_pie,
        'activeIcon': TablerIcons.chart_pie
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
              },
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 68,
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
