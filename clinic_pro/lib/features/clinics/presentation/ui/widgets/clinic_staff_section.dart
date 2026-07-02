import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../staff/presentation/ui/widgets/invite_staff_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/clinics_cubit.dart';
import '../../manager/clinics_state.dart';
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
    return BlocBuilder<ClinicsCubit, ClinicsState>(
      builder: (context, state) {
        final staffEntries = MockData.clinicStaff
            .where((cs) =>
                cs['clinic_id'] == clinicId && cs['is_active'] == true)
            .toList();

        final staffList = staffEntries.map((entry) {
          final userId = entry['user_id'] as String;
          final role = entry['role'] as String;
          final userData = MockData.users.firstWhere(
            (u) => u['id'] == userId,
            orElse: () => <String, dynamic>{},
          );

          return {
            'staff_entry_id': entry['id'] as String,
            'name': userData['name'] as String? ?? '',
            'role': role,
            'specialty': userData['specialty'] as String? ?? '',
            'avatar_url': userData['avatar_url'] as String?,
            'rating': (userData['rating'] as num?)?.toDouble() ?? 0,
          };
        }).toList();

        return Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            border: Border.all(color: AppColors.border),
            boxShadow: AppConstants.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      size: AppConstants.iconSizeLg, color: AppColors.primary),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    AppStrings.staff,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: AppConstants.iconSizeMd, color: AppColors.primary),
                    label: Text(
                      AppStrings.addMember,
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showAddMemberOptions(context),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    AppStrings.viewAll,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm + AppConstants.spaceXs),
              if (staffList.isEmpty)
                Text(
                  AppStrings.noStaff,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textHint,
                  ),
                )
              else
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: staffList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppConstants.spaceSm + AppConstants.spaceXs),
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      final name = staff['name'] as String;
                      final role = staff['role'] as String;
                      final specialty = staff['specialty'] as String;
                      final avatarUrl = staff['avatar_url'] as String?;
                      final rating = staff['rating'] as double;

                      final initials = name
                          .trim()
                          .split(' ')
                          .where((p) => p.isNotEmpty)
                          .map((p) => p[0])
                          .take(2)
                          .join();

                      final roleLabel = _roleLabel(role);
                      final displaySpecialty =
                          specialty.isNotEmpty ? specialty : roleLabel;

                      final staffEntryId = staff['staff_entry_id'] as String;

                      return StaffMemberCard(
                        name: name,
                        displaySpecialty: displaySpecialty,
                        avatarUrl: avatarUrl,
                        rating: rating,
                        initials: initials,
                        staffEntryId: staffEntryId,
                        onRemove: () => _confirmRemoveStaff(
                            context, name, staffEntryId),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemoveStaff(
      BuildContext context, String staffName, String staffEntryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.removeFromStaff,
            style: AppTextStyles.headlineSmall(ctx).copyWith(
                fontWeight: FontWeight.bold)),
        content: Text(AppStrings.confirmRemoveStaff(staffName),
            style: AppTextStyles.bodyMedium(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel,
                style: AppTextStyles.bodyMedium(ctx).copyWith(
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<ClinicsCubit>()
                  .removeStaffMember(staffEntryId);
            },
            child: Text(AppStrings.remove,
                style: AppTextStyles.bodyMedium(ctx).copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    return AppStrings.roleLabel(role);
  }

  void _showAddMemberOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusCard)),
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
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined,
                  color: AppColors.primary),
              title: Text(AppStrings.newMember,
                  style: AppTextStyles.headlineSmall(ctx).copyWith(
                      fontWeight: FontWeight.bold)),
              subtitle: Text(AppStrings.newMemberDesc,
                  style: AppTextStyles.bodyMedium(ctx)),
              onTap: () {
                Navigator.pop(ctx);
                InviteStaffSheet.show(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.swap_horiz_outlined,
                  color: AppColors.primary),
              title: Text(AppStrings.existingMember,
                  style: AppTextStyles.headlineSmall(ctx).copyWith(
                      fontWeight: FontWeight.bold)),
              subtitle: Text(AppStrings.existingMemberDesc,
                  style: AppTextStyles.bodyMedium(ctx)),
              onTap: () {
                Navigator.pop(ctx);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(AppConstants.radiusCard)),
                  ),
                  builder: (sheetCtx) => AddExistingStaffSheet(
                    clinicId: clinicId,
                    onAdd: (userId, role) {
                      context.read<ClinicsCubit>().addStaffMember(
                            clinicId: clinicId,
                            userId: userId,
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
