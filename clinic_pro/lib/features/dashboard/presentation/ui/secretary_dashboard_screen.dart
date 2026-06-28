import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../appointments/presentation/ui/appointments_screen.dart';
import '../manager/secretary_dashboard_cubit.dart';
import '../manager/secretary_dashboard_state.dart';
import 'widgets/live_queue_section.dart';
import 'widgets/today_appointments_list.dart';
import 'widgets/daily_summary_row.dart';

class SecretaryDashboardScreen extends StatefulWidget {
  const SecretaryDashboardScreen({super.key});

  @override
  State<SecretaryDashboardScreen> createState() => _SecretaryDashboardScreenState();
}

class _SecretaryDashboardScreenState extends State<SecretaryDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SecretaryDashboardCubit()..loadDashboardData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentIndex == 0 ? _buildAppBar(context) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildMainDashboardTab(),
            const AppointmentsScreen(),
            _buildPlaceholderTab('الفواتير والحسابات', Icons.receipt_long_outlined),
            _buildPlaceholderTab('الإعدادات', Icons.settings_outlined),
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
      title: BlocBuilder<SecretaryDashboardCubit, SecretaryDashboardState>(
        builder: (context, state) {
          String sub = 'مكتب الاستقبال';
          if (state is SecretaryDashboardLoaded) {
            sub = 'مرحباً، ${state.secretaryName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الاستقبال والعيادة',
                style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                sub,
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
              Icons.support_agent,
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
    return BlocBuilder<SecretaryDashboardCubit, SecretaryDashboardState>(
      builder: (context, state) {
        if (state is SecretaryDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SecretaryDashboardError) {
          return Center(child: Text(state.message));
        }
        if (state is SecretaryDashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SecretaryDashboardCubit>().loadDashboardData();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                DailySummaryRow(
                  totalInvoiced: state.totalInvoiced,
                  totalCollected: state.totalCollected,
                  totalAppointmentsCount: state.totalAppointmentsCount,
                ),
                const SizedBox(height: 24),
                LiveQueueSection(
                  queue: state.liveQueue,
                  onCall: (appId) {
                    context.read<SecretaryDashboardCubit>().callPatient(appId);
                  },
                ),
                const SizedBox(height: 24),
                TodayAppointmentsList(
                  appointments: state.todayAppointments,
                  onConfirmArrival: (appId) {
                    context.read<SecretaryDashboardCubit>().confirmArrival(appId);
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

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headlineMedium(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذه الشاشة قيد التطوير والمحاكاة',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'label': 'الرئيسية', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
      {'label': 'المواعيد', 'icon': Icons.calendar_today_outlined, 'activeIcon': Icons.calendar_today},
      {'label': 'الفواتير', 'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long},
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
