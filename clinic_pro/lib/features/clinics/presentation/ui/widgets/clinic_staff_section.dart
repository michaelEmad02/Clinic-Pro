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
                      onPressed: () => _showAddMemberOptions(context),
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

                        final roleLabel = staff.role.label;

                        final staffEntryId = staff.id;

                        return StaffMemberCard(
                          name: staff.name,
                          displaySpecialty: roleLabel,
                          initials: initials,
                          staffEntryId: staffEntryId,
                          onRemove: () => _confirmRemoveStaff(context,
                              staff.name, staffEntryId, staff.role.name),
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

  void _confirmRemoveStaff(BuildContext context, String staffName,
      String staffEntryId, String role) {
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
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ClinicsCubit>().removeStaffMember(
                    clinicId: clinicId,
                    staffId: staffEntryId,
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

  void _showAddMemberOptions(BuildContext context) {
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppConstants.radiusCard)),
                  ),
                  builder: (sheetCtx) => AddExistingStaffSheet(
                    clinicId: clinicId,
                    onAdd: (userId, role) {
                      context.read<ClinicsCubit>().addStaffMember(
                            clinicId: clinicId,
                            userId: userId,
                            doctorId: "",
                            role: role,
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
