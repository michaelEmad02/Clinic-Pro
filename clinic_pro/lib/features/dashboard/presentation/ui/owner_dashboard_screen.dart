import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../clinics/presentation/ui/clinics_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../manager/owner_dashboard_cubit.dart';
import '../manager/owner_dashboard_state.dart';
import 'widgets/dashboard_summary_row.dart';
import 'widgets/alerts_section.dart';
import 'widgets/revenue_bar_chart.dart';
import 'widgets/quick_actions_row.dart';
import '../../../reports/presentation/ui/reports_screen.dart';
import '../../../expenses/presentation/ui/expenses_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OwnerDashboardCubit(sl<ICloudService>())..loadDashboardData(),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: _currentIndex == 0 ? _buildAppBar(context) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildMainDashboardTab(),
            const ClinicsScreen(),
            const ExpensesScreen(),
            const ReportsScreen(),
            const SettingsScreen(role: StaffRoles.owner, showBottomNav: false),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
        builder: (context, state) {
          String subtitle = AppStrings.isArabic ? 'لوحة التحكم' : 'Dashboard';
          if (state is OwnerDashboardLoaded) {
            subtitle = '${AppStrings.welcomeBack}${state.dashboard.ownerName}';
          }
          return Column(
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
                subtitle,
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
        //   icon:  Icon(Icons.notifications_none_outlined,
        //       color: context.textSecondary),
        //   onPressed: () {},
        // ),
        // const SizedBox(width: 8),
        // Container(
        //   margin: const EdgeInsets.only(left: 16),
        //   width: 36,
        //   height: 36,
        //   decoration:  BoxDecoration(
        //     color: context.primaryLightColor,
        //     shape: BoxShape.circle,
        //   ),
        //   child: const Center(
        //     child: Icon(
        //       Icons.person,
        //       color: context.primary,
        //       size: 20,
        //     ),
        //   ),
        // ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: context.border,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMainDashboardTab() {
    return BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
      builder: (context, state) {
        if (state is OwnerDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OwnerDashboardError) {
          return Center(child: Text(state.message));
        }
        if (state is OwnerDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<OwnerDashboardCubit>().loadDashboardData();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                DashboardSummaryRow(
                  totalRevenue: state.dashboard.totalRevenue,
                  totalPatients: state.dashboard.totalPatients,
                  todayAppointments: state.dashboard.todayAppointments,
                  activeClinics: state.dashboard.activeClinics,
                ),
                const SizedBox(height: 24),
                AlertsSection(alerts: state.dashboard.alerts),
                const SizedBox(height: 24),
                // ClinicsHorizontalScroll(clinics: state.dashboard.clinics),
                // const SizedBox(height: 24),
                RevenueBarChart(weeklyRevenue: state.dashboard.weeklyRevenue),
                const SizedBox(height: 24),
                const QuickActionsRow(),
              ],
            ),
          );
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
