import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../manager/staff_cubit.dart';
import '../manager/staff_state.dart';
import 'widgets/clinic_filter_chips.dart';
import 'widgets/pending_invitations_section.dart';
import 'widgets/staff_action_sheet.dart';
import 'widgets/staff_filter_chips.dart';
import 'widgets/staff_list.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffCubit(sl<ICloudService>())..loadStaff(),
      child: const _StaffBody(),
    );
  }
}

class _StaffBody extends StatelessWidget {
  const _StaffBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الطاقم الطبي',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'إدارة الأطباء والممرضين والموظفين',
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<StaffCubit, StaffState>(
        builder: (context, state) {
          if (state is StaffLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6),
            );
          }
          if (state is StaffError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<StaffCubit>().loadStaff(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is StaffLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StaffCubit>().loadStaff();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ClinicFilterChips(
                    clinics: state.clinics,
                    selectedClinicId: state.selectedClinicId,
                    onChanged: (clinicId) =>
                        context.read<StaffCubit>().changeClinicFilter(clinicId),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'تصفية حسب الدور',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StaffFilterChips(
                    activeFilter: state.activeFilter,
                    onChanged: (f) =>
                        context.read<StaffCubit>().changeFilter(f),
                  ),
                  const SizedBox(height: 16),
                  if (state.pendingInvitations.isNotEmpty) ...[
                    PendingInvitationsSection(
                      invitations: state.pendingInvitations,
                      onResend: (inv) =>
                          context.read<StaffCubit>().resendInvitation(inv.id),
                      onCancel: (inv) =>
                          context.read<StaffCubit>().cancelInvitation(inv.id),
                    ),
                    const SizedBox(height: 12),
                  ],
                  StaffList(
                    staffList: state.filteredStaff,
                    onItemTap: (s) => _showActions(context, s),
                    onItemMore: (s) => _showActions(context, s),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(RouteConstants.onboardingInvite, extra: {'isOnboarding': false}).then((_) {
            if (context.mounted) {
              context.read<StaffCubit>().loadStaff();
            }
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person_add_alt_1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showActions(BuildContext context, StaffItem staff) {
    StaffActionSheet.show(
      context: context,
      staff: staff,
      onEditRole: () => _pickRole(context, staff),
      onToggleSuspend: () async {
        await context.read<StaffCubit>().toggleSuspend(staff.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                staff.isActive ? 'تم تعليق حساب الموظف' : 'تم إعادة تفعيل الحساب'),
          ),
        );
      },
    );
  }

  Future<void> _pickRole(BuildContext context, StaffItem staff) async {
    final staffCubit = context.read<StaffCubit>();
    final allowedRoles = [StaffRoles.doctor, StaffRoles.secretary];
    final selectedRole = await showDialog<StaffRoles>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('تغيير الدور'),
        children: allowedRoles.map((role) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, role),
            child: Text(role.label),
          );
        }).toList(),
      ),
    );
    if (selectedRole == null) return;
    await staffCubit.updateStaffRole(staff.id, selectedRole.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تغيير الدور إلى ${staff.roleLabel}')),
    );
  }
}
