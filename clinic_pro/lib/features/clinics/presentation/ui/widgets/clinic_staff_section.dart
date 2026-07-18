import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_state.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/fetch_clinic_staff_cubit.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/cubit/clinics_cubit.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import 'staff_member_card.dart';
import 'add_existing_staff_sheet.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../staff/domain/entities/staff_entity.dart';

class ClinicStaffSection extends StatelessWidget {
  final String clinicId;

  const ClinicStaffSection({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchClinicStaffCubit, FetchClinicStaffState>(
      builder: (context, state) {
        // final staffEntries = MockData.clinicStaff
        //     .where(
        //         (cs) => cs['clinic_id'] == clinicId && cs['is_active'] == true)
        //     .toList();

        // final staffList = staffEntries.map((entry) {
        //   final userId = entry['user_id'] as String;
        //   final role = entry['role'] as String;
        //   final userData = MockData.users.firstWhere(
        //     (u) => u['id'] == userId,
        //     orElse: () => <String, dynamic>{},
        //   );

        //   return {
        //     'staff_entry_id': entry['id'] as String,
        //     'name': userData['name'] as String? ?? '',
        //     'role': role,
        //     'specialty': userData['specialty'] as String? ?? '',
        //     'avatar_url': userData['avatar_url'] as String?,
        //     'rating': (userData['rating'] as num?)?.toDouble() ?? 0,
        //   };
        // }).toList();
        if (state is FetchClinicStaffLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FetchClinicStaffFailure) {
          return Center(child: Text(AppStrings.loadFailed));
        } else if (state is FetchClinicStaffLoaded) {
          var ownerId =
              (context.read<AuthCubit>().state as AuthAuthenticated).user.id;
          return Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              border: Border.all(color: context.border),
              boxShadow: AppConstants.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        size: AppConstants.iconSizeLg, color: context.primary),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      AppStrings.staff,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: Icon(Icons.add,
                          size: AppConstants.iconSizeMd,
                          color: context.primary),
                      label: Text(
                        AppStrings.addMember,
                        style: AppTextStyles.labelChip(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _showAddMemberOptions(context, ownerId),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Text(
                      AppStrings.viewAll,
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: AppConstants.spaceSm + AppConstants.spaceXs),
                if (state.clinicStaff.isEmpty)
                  Text(
                    AppStrings.noStaff,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textHint,
                    ),
                  )
                else
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.clinicStaff.length,
                      separatorBuilder: (_, __) => const SizedBox(
                          width: AppConstants.spaceSm + AppConstants.spaceXs),
                      itemBuilder: (context, index) {
                        final staff = state.clinicStaff[index];

                        final initials = staff.name
                            .trim()
                            .split(' ')
                            .where((p) => p.isNotEmpty)
                            .map((p) => p[0])
                            .take(2)
                            .join();

                        final displaySpecialty = staff.specialty != null && staff.specialty!.isNotEmpty
                            ? staff.specialty!
                            : staff.role.label;

                        final doctorId = (staff.doctorSecretaries != null &&
                                staff.doctorSecretaries!.isNotEmpty)
                            ? staff.doctorSecretaries!.first.doctorId
                            : null;

                        final staffEntryId = staff.id;

                        return StaffMemberCard(
                          name: staff.name,
                          displaySpecialty: displaySpecialty,
                          initials: initials,
                          staffEntryId: staffEntryId,
                          onRemove: () => _confirmRemoveStaff(
                              context: context,
                              staffName: staff.name,
                              staffEntryId: staff.userId,
                              role: staff.role.name,
                              ownerId: ownerId,
                              doctorId: doctorId),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }
        return const Center();
      },
    );
  }

  void _confirmRemoveStaff({
    required BuildContext context,
    required String staffName,
    required String staffEntryId,
    required String role,
    required String ownerId,
    String? doctorId,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.removeFromStaff,
            style: AppTextStyles.headlineSmall(ctx)
                .copyWith(fontWeight: FontWeight.bold)),
        content: Text(AppStrings.confirmRemoveStaff(staffName),
            style: AppTextStyles.bodyMedium(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel,
                style: AppTextStyles.bodyMedium(ctx)
                    .copyWith(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ClinicsCubit>().removeStaffMember(
                    clinicId: clinicId,
                    staffId: staffEntryId,
                    ownerId: ownerId,
                    doctorId: doctorId,
                  );
              if (!context.mounted) return;
              context.read<FetchClinicStaffCubit>().fetchClinicStaff(clinicId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppStrings.deletedSuccess} $staffName'),
                  backgroundColor: context.successText,
                ),
              );
            },
            child: Text(AppStrings.remove,
                style: AppTextStyles.bodyMedium(ctx).copyWith(
                    color: context.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberOptions(BuildContext context, String ownerId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusCard)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.addMemberToStaff,
              style: AppTextStyles.headlineSmall(ctx).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ListTile(
              leading:
                  Icon(Icons.person_add_alt_1_outlined, color: context.primary),
              title: Text(AppStrings.newMember,
                  style: AppTextStyles.headlineSmall(ctx)
                      .copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(AppStrings.newMemberDesc,
                  style: AppTextStyles.bodyMedium(ctx)
                      .copyWith(color: context.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                context.push(RouteConstants.onboardingInvite,
                    extra: {'isOnboarding': false});
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.swap_horiz_outlined, color: context.primary),
              title: Text(AppStrings.existingMember,
                  style: AppTextStyles.headlineSmall(ctx)
                      .copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(AppStrings.existingMemberDesc,
                  style: AppTextStyles.bodyMedium(ctx)
                      .copyWith(color: context.textSecondary)),
              onTap: () {
                Navigator.pop(ctx);
                // جلب أطباء العيادة الحالية لتمريرها للـ sheet
                final clinicStaffState =
                    context.read<FetchClinicStaffCubit>().state;
                final clinicDoctors =
                    clinicStaffState is FetchClinicStaffLoaded
                        ? clinicStaffState.clinicStaff
                            .where((s) => s.role == StaffRoles.doctor)
                            .toList()
                        : <StaffEntity>[];

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusCard)),
                  ),
                  builder: (sheetCtx) => AddExistingStaffSheet(
                    clinicId: clinicId,
                    clinicDoctors: clinicDoctors,
                    onAdd: (userId, role, doctorId) async {
                      await context.read<ClinicsCubit>().addStaffMember(
                          clinicId: clinicId,
                          userId: userId,
                          doctorId: doctorId,
                          role: role,
                          ownerId: ownerId);
                      if (!context.mounted) return;
                      context
                          .read<FetchClinicStaffCubit>()
                          .fetchClinicStaff(clinicId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${AppStrings.addedSuccess} $userId'),
                          backgroundColor: context.successText,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
