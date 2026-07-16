import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';
import '../../../clinics/presentation/manager/cubit/clinics_cubit.dart';
import '../../../clinics/presentation/manager/cubit/clinics_state.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
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
    var ownerId =
        (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<StaffCubit>()..fetchAllStaff(ownerId),
        ),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(),
        ),
      ],
      child: _StaffBody(
        ownerId: ownerId,
      ),
    );
  }
}

class _StaffBody extends StatelessWidget {
  final String ownerId;
  const _StaffBody({required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final clinicsState = context.watch<ClinicsCubit>().state;
    final clinicsList = clinicsState is ClinicsLoaded
        ? clinicsState.clinics
        : const <ClinicEntity>[];

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.isArabic ? 'إدارة الموظفين' : 'Staff Management',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              AppStrings.manageStaff,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.border, height: 1),
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
                        context.read<StaffCubit>().fetchAllStaff(ownerId),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is StaffLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<StaffCubit>().fetchAllStaff(ownerId);
                context.read<ClinicsCubit>().fetchClinics();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ClinicFilterChips(
                    clinics: clinicsList,
                    selectedClinicId: state.selectedClinicId,
                    onChanged: (clinicId) =>
                        context.read<StaffCubit>().changeClinicFilter(clinicId),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppStrings.filterByRole,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
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
          context.push(RouteConstants.onboardingInvite,
              extra: {'isOnboarding': false}).then((_) {
            if (context.mounted) {
              context.read<StaffCubit>().fetchAllStaff(ownerId);
            }
          });
        },
        backgroundColor: context.primary,
        foregroundColor: context.surfaceBright,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person_add_alt_1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showActions(BuildContext context, StaffEntity staff) {
    StaffActionSheet.show(
      context: context,
      staff: staff,
      onEditRole: () => _pickRole(context, staff),
      onToggleSuspend: () async {
        await context.read<StaffCubit>().toggleSuspend(staff.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(staff.isActive
                ? AppStrings.accountSuspended
                : AppStrings.accountReactivated),
          ),
        );
      },
      onDelete: () async {
        await context.read<StaffCubit>().deleteStaff(staff.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.isArabic ? 'تم حذف الموظف بنجاح' : 'Staff deleted successfully'),
          ),
        );
      },
    );
  }

  Future<void> _pickRole(BuildContext context, StaffEntity staff) async {
    final staffCubit = context.read<StaffCubit>();
    final allowedRoles = [StaffRoles.doctor, StaffRoles.secretary];
    final selectedRole = await showDialog<StaffRoles>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(AppStrings.changeRole),
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
      SnackBar(content: Text('${AppStrings.roleChanged}${staff.role.label}')),
    );
  }
}
