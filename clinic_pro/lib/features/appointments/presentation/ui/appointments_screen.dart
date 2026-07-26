// ────────────────────────────────────────────────────────
// شاشة المواعيد الرئيسية — تجمع التبويبات والقائمة وFAB
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import '../../../invoices/presentation/ui/widgets/add_invoice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/appointment_entity.dart';
import '../manager/appointments_bloc.dart';
import '../manager/appointments_event.dart';
import '../manager/appointments_state.dart';
import 'widgets/add_appointment_sheet.dart';
import 'widgets/appointment_action_sheet.dart';
import 'widgets/appointments_list.dart';
import 'widgets/appointments_tab_bar.dart';
import '../../../settings/presentation/manager/settings_state.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().state.user!;

    return BlocProvider(
      create: (_) => sl<AppointmentsBloc>(),
      child: _AppointmentsBody(currentUser: currentUser),
    );
  }
}

class _AppointmentsBody extends StatefulWidget {
  const _AppointmentsBody({required this.currentUser});
  final dynamic currentUser;

  @override
  State<_AppointmentsBody> createState() => _AppointmentsBodyState();
}

class _AppointmentsBodyState extends State<_AppointmentsBody> {
  String _clinicId = '';
  String _doctorId = '';
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // محاولة التحميل الأولي عند توفر البيانات
    _tryLoadAppointments();
  }

  /// استخراج clinicId و doctorId من SettingsCubit وتحميل المواعيد
  void _tryLoadAppointments() {
    final settingsState = context.read<SettingsCubit>().state;
    final newClinicId = settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final settingsDoctorId = settingsState.currentDoctorId;

    String newDoctorId;
    if (widget.currentUser.role == StaffRoles.doctor) {
      newDoctorId = widget.currentUser.id;
    } else {
      newDoctorId = (settingsDoctorId != null && settingsDoctorId.isNotEmpty)
          ? settingsDoctorId
          : AppConstants.activeDoctorId;
    }

    // لا نعيد التحميل إذا لم تتغيّر القيم وكان التحميل قد تمّ
    if (_hasLoaded && newClinicId == _clinicId && newDoctorId == _doctorId) return;
    // لا نحمل إذا كان clinicId فارغاً (الإعدادات لم تجهز بعد)
    if (newClinicId.isEmpty) return;

    _clinicId = newClinicId;
    _doctorId = newDoctorId;
    _hasLoaded = true;

    context.read<AppointmentsBloc>().add(
      LoadAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع لتغيّرات SettingsCubit — عند تحميل العيادة نعيد جلب المواعيد
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, settingsState) {
        _tryLoadAppointments();
      },
      child: Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.appointments,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        actions: [
          IconButton(
            icon:  Icon(Icons.queue_outlined, color: context.primary),
            tooltip: AppStrings.queueTooltip,
            onPressed: () => context.push(RouteConstants.waitingQueue),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        buildWhen: (previous, current) {
          // إعادة البناء فقط عند تغير النوع أو المحتوى أو حالة التحميل/الخطأ
          return previous.runtimeType != current.runtimeType ||
              (previous is AppointmentsLoaded &&
                  current is AppointmentsLoaded &&
                  (previous.activeTab != current.activeTab ||
                      previous.statusFilter != current.statusFilter ||
                      previous.filteredAppointments != current.filteredAppointments));
        },
        builder: (context, state) {
          // حالة عدم جهوزية الإعدادات بعد
          if (state is AppointmentsInitial && !_hasLoaded) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6),
            );
          }
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
                    onPressed: () => context
                        .read<AppointmentsBloc>()
                        .add(LoadAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId)),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is AppointmentsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AppointmentsBloc>()
                    .add(LoadAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId));
                await Future.delayed(const Duration(milliseconds: 200));
              },
              child: ResponsiveHelper.responsiveCenter(
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
                      onItemTap: (item) => context
                          .push('${RouteConstants.appointments}/${item.id}'),
                      onItemMore: (item) => _showActions(context, item),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddAppointmentSheet.show(context),
        backgroundColor: context.primary,
        foregroundColor: context.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.newAppointment),
      ),
      ),
    );
  }

  void _showActions(BuildContext context, AppointmentEntity item) {
    final bloc = context.read<AppointmentsBloc>();
    AppointmentActionSheet.show(
      context: context,
      appointment: item,
      onConfirmArrival: item.status == AppointmentStatus.scheduled
          ? () => bloc.add(ConfirmArrivalEvent(item.id))
          : null,
      onToggleUrgent: () => bloc.add(ToggleUrgentEvent(item.id)),
      onCancel: item.status != AppointmentStatus.done && item.status != AppointmentStatus.cancelled
          ? () => _confirmCancel(context, item, bloc)
          : null,
      onRegisterInvoice: () async {
        await AddInvoiceSheet.show(context, initialAppointmentId: item.id);
        if (context.mounted) {
          bloc.add(LoadAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId));
        }
      },
      onViewDetails: () =>
          context.push('${RouteConstants.appointments}/${item.id}'),
      onEdit: () async {
        await AddAppointmentSheet.show(context, appointment: item);
        if (context.mounted) {
          bloc.add(LoadAppointmentsEvent(doctorId: _doctorId, clinicId: _clinicId));
        }
      },
      onDelete: () => _confirmDelete(context, item, bloc),
    );
  }

  void _confirmCancel(
      BuildContext context, AppointmentEntity item, AppointmentsBloc bloc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppStrings.cancel} ${AppStrings.appointment}'),
        content: Text(AppStrings.cancelAppointmentWithInvoice(item.hasInvoice)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(CancelAppointmentEvent(item.id));
            },
            style: TextButton.styleFrom(foregroundColor: context.danger),
            child: Text(AppStrings.confirmCancel),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppointmentEntity item, AppointmentsBloc bloc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAppointmentTitle),
        content: Text(AppStrings.confirmDeleteAppointmentMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(DeleteAppointmentEvent(item.id));
            },
            style: TextButton.styleFrom(foregroundColor: context.danger),
            child: Text(AppStrings.confirmDelete),
          ),
        ],
      ),
    );
  }
}
