import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/doctor_dashboard_cubit.dart';
import '../manager/doctor_dashboard_state.dart';
import 'widgets/current_patient_card.dart';
import 'widgets/waiting_queue_list.dart';
import 'widgets/doctor_stats_row.dart';

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
      create: (context) => DoctorDashboardCubit()..loadDashboardData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentIndex == 0 ? _buildAppBar(context) : null,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildMainDashboardTab(),
            _buildPlaceholderTab('المواعيد والجدول', Icons.calendar_today_outlined),
            _buildPlaceholderTab('قائمة المرضى والسجلات', Icons.people_alt_outlined),
            _buildPlaceholderTab('الإعدادات الشخصية', Icons.settings_outlined),
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
      title: BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
        builder: (context, state) {
          String doctorName = 'أهلاً بك يا دكتور';
          if (state is DoctorDashboardLoaded) {
            doctorName = 'مرحباً، ${state.doctorName}';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عيادتك المتكاملة',
                style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                doctorName,
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
              Icons.healing_outlined,
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
                CurrentPatientCard(
                  patient: state.currentPatient,
                  onStartExamination: () {
                    // Start examination flow, go to prescription
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
      {'label': 'المرضى', 'icon': Icons.people_alt_outlined, 'activeIcon': Icons.people},
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
