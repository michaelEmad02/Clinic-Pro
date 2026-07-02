import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class AddExistingStaffSheet extends StatefulWidget {
  final String clinicId;
  final Function(String userId, String role) onAdd;

  const AddExistingStaffSheet({
    super.key,
    required this.clinicId,
    required this.onAdd,
  });

  @override
  State<AddExistingStaffSheet> createState() => _AddExistingStaffSheetState();
}

class _AddExistingStaffSheetState extends State<AddExistingStaffSheet> {
  String? _selectedUserId;
  StaffRoles _selectedRoleFilter = StaffRoles.doctor;

  @override
  Widget build(BuildContext context) {
    final currentClinic = MockData.clinics.firstWhere(
      (c) => c['id'] == widget.clinicId,
      orElse: () => <String, dynamic>{},
    );
    final ownerId = currentClinic['owner_id'] ?? 'u-owner-1';

    final ownerClinics = MockData.clinics
        .where((c) => c['owner_id'] == ownerId)
        .map((c) => c['id'] as String)
        .toSet();

    final currentClinicUserIds = MockData.clinicStaff
        .where((cs) => cs['clinic_id'] == widget.clinicId)
        .map((cs) => cs['user_id'] as String)
        .toSet();

    final otherStaffEntries = MockData.clinicStaff
        .where((cs) =>
            ownerClinics.contains(cs['clinic_id']) &&
            cs['clinic_id'] != widget.clinicId &&
            cs['role'] == _selectedRoleFilter.name &&
            !currentClinicUserIds.contains(cs['user_id']))
        .toList();

    final otherStaffUserIds =
        otherStaffEntries.map((cs) => cs['user_id'] as String).toSet();

    final otherStaff =
        MockData.users.where((u) => otherStaffUserIds.contains(u['id'])).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppConstants.spaceMd,
        right: AppConstants.spaceMd,
        top: AppConstants.spaceMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.existingMember,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppConstants.spaceMd),
          Text(
            AppStrings.filterByRole,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppConstants.spaceSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: StaffRoles.values.map((role) {
                final isSelected = _selectedRoleFilter == role;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
                  child: ChoiceChip(
                    avatar: Icon(role.icon,
                        size: 14,
                        color: isSelected ? AppColors.onPrimary : AppColors.primary),
                    label: Text(role.label,
                        style: AppTextStyles.bodyMedium(context)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedRoleFilter = role;
                          _selectedUserId = null;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: AppConstants.spaceMd),
          Text(
            AppStrings.selectMember,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppConstants.spaceSm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: otherStaff.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
                      child: Text(
                        AppStrings.noMembersInRole,
                        style: AppTextStyles.bodyMedium(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: otherStaff.length,
                    itemBuilder: (ctx, idx) {
                      final u = otherStaff[idx];
                      final isSelected = _selectedUserId == u['id'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primaryLight
                              : AppColors.surfaceContainerLow,
                          child: Text(
                              u['name'].toString().substring(0, 1)),
                        ),
                        title: Text(u['name'],
                            style: AppTextStyles.bodyMedium(context)),
                        subtitle: Text(u['specialty'] ?? '',
                            style: AppTextStyles.caption(context)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedUserId = u['id'] as String;
                          });
                        },
                      );
                    },
                  ),
          ),
          SizedBox(height: AppConstants.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedUserId == null
                  ? null
                  : () {
                      widget.onAdd(
                          _selectedUserId!, _selectedRoleFilter.name);
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(AppStrings.addToClinicSameRole,
                  style: AppTextStyles.bodyMedium(context)),
            ),
          ),
        ],
      ),
    );
  }
}
