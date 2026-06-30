import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../clinics/presentation/ui/clinics_screen.dart';
import '../../../settings/presentation/ui/settings_screen.dart';
import '../manager/owner_dashboard_cubit.dart';
import '../manager/owner_dashboard_state.dart';
import 'widgets/dashboard_summary_row.dart';
import 'widgets/clinics_horizontal_scroll.dart';
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
      create: (context) => OwnerDashboardCubit()..loadDashboardData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
        builder: (context, state) {
          String subtitle = 'لوحة التحكم';
          if (state is OwnerDashboardLoaded) {
            subtitle = 'مرحباً، ${state.ownerName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'كلينك برو',
                style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(left: 16),
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.border,
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
                  totalRevenue: state.totalRevenue,
                  totalPatients: state.totalPatients,
                  todayAppointments: state.todayAppointments,
                  activeClinics: state.activeClinics,
                ),
                const SizedBox(height: 24),
                AlertsSection(alerts: state.alerts),
                const SizedBox(height: 24),
                ClinicsHorizontalScroll(clinics: state.clinics),
                const SizedBox(height: 24),
                RevenueBarChart(weeklyRevenue: state.weeklyRevenue),
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
      {'label': 'الرئيسية', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
      {'label': 'العيادات', 'icon': Icons.business_outlined, 'activeIcon': Icons.business},
      {'label': 'المصاريف', 'icon': Icons.money_off_outlined, 'activeIcon': Icons.money_off},
      {'label': 'التقارير', 'icon': Icons.analytics_outlined, 'activeIcon': Icons.analytics},
      {'label': 'الإعدادات', 'icon': Icons.settings_outlined, 'activeIcon': Icons.settings},
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Row(
                children: [
                  Icon(
                    isSelected ? (tab['activeIcon'] as IconData) : (tab['icon'] as IconData),
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
