// ────────────────────────────────────────────────────────
// شاشة المواعيد الرئيسية — تجمع التبويبات والقائمة وFAB
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/appointments_bloc.dart';
import '../manager/appointments_event.dart';
import '../manager/appointments_state.dart';
import 'widgets/add_appointment_sheet.dart';
import 'widgets/appointment_action_sheet.dart';
import 'widgets/appointments_list.dart';
import 'widgets/appointments_tab_bar.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppointmentsBloc()..add(LoadAppointmentsEvent()),
      child: const _AppointmentsBody(),
    );
  }
}

class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'المواعيد',
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_outlined, color: AppColors.primary),
            tooltip: 'طابور الانتظار',
            onPressed: () => context.push(RouteConstants.waitingQueue),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          if (state is AppointmentsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6),
            );
          }
          if (state is AppointmentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AppointmentsBloc>().add(LoadAppointmentsEvent()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is AppointmentsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AppointmentsBloc>().add(LoadAppointmentsEvent());
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  AppointmentsTabBar(
                    activeTab: state.activeTab,
                    onTabChanged: (tab) => context
                        .read<AppointmentsBloc>()
                        .add(ChangeAppointmentsTabEvent(tab)),
                  ),
                  const SizedBox(height: 16),
                  AppointmentsList(
                    appointments: state.filteredAppointments,
                    statusFilter: state.statusFilter,
                    onFilterChanged: (filter) => context
                        .read<AppointmentsBloc>()
                        .add(ChangeStatusFilterEvent(filter)),
                    onItemTap: (item) =>
                        context.push('${RouteConstants.appointments}/${item.id}'),
                    onItemMore: (item) => _showActions(context, item),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddAppointmentSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('موعد جديد'),
      ),
    );
  }

  void _showActions(BuildContext context, AppointmentItem item) {
    final bloc = context.read<AppointmentsBloc>();
    AppointmentActionSheet.show(
      context: context,
      appointment: item,
      onConfirmArrival: item.status == 'scheduled'
          ? () => bloc.add(ConfirmArrivalEvent(item.id))
          : null,
      onToggleUrgent: () => bloc.add(ToggleUrgentEvent(item.id)),
      onCancel: item.status != 'done' && item.status != 'cancelled'
          ? () => bloc.add(CancelAppointmentEvent(item.id))
          : null,
      onViewDetails: () =>
          context.push('${RouteConstants.appointments}/${item.id}'),
    );
  }
}
