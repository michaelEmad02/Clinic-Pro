import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
import '../../../../staff/domain/entities/staff_entity.dart';
import '../../../../staff/presentation/manager/staff_cubit.dart';
import '../../../../staff/presentation/manager/staff_state.dart';

class AddExistingStaffSheet extends StatefulWidget {
  final String clinicId;
  final Function(String userId, StaffRoles role) onAdd;

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
    final authState = context.read<AuthCubit>().state;
    final ownerId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (ctx) => sl<StaffCubit>()..fetchAllStaff(ownerId),
      child: BlocBuilder<StaffCubit, StaffState>(
        builder: (ctx, state) {
          final otherStaff = state is StaffLoaded
              ? _filterStaff(state.allStaff)
              : <StaffEntity>[];

          return Padding(
            padding: EdgeInsets.only(
              left: AppConstants.spaceMd,
              right: AppConstants.spaceMd,
              top: AppConstants.spaceMd,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  AppConstants.spaceLg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.existingMember,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Text(
                  AppStrings.filterByRole,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: StaffRoles.values.map((role) {
                      final isSelected = _selectedRoleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceXs),
                        child: ChoiceChip(
                          avatar: Icon(role.icon,
                              size: 14,
                              color: isSelected
                                  ? context.onPrimary
                                  : context.primary),
                          label: Text(role.label,
                              style: AppTextStyles.bodyMedium(context)),
                          selected: isSelected,
                          selectedColor: context.primary,
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
                const SizedBox(height: AppConstants.spaceMd),
                Text(
                  AppStrings.selectMember,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: state is StaffLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.spaceLg),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : state is StaffError
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppConstants.spaceLg),
                                child: Text(
                                  state.message,
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(color: context.danger),
                                ),
                              ),
                            )
                          : otherStaff.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: AppConstants.spaceLg),
                                    child: Text(
                                      AppStrings.noMembersInRole,
                                      style: AppTextStyles.bodyMedium(context)
                                          .copyWith(
                                              color: context.textSecondary),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: otherStaff.length,
                                  itemBuilder: (ctx, idx) {
                                    final s = otherStaff[idx];
                                    final isSelected =
                                        _selectedUserId == s.userId;
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isSelected
                                            ? context.primaryLightColor
                                            : context.surfaceContainerLow,
                                        child: Text(s.name.substring(0, 1)),
                                      ),
                                      title: Text(s.name,
                                          style: AppTextStyles
                                              .bodyMedium(context)),
                                      subtitle: Text(
                                          s.specialty ?? '',
                                          style:
                                              AppTextStyles.caption(context)),
                                      trailing: isSelected
                                          ? Icon(Icons.check_circle,
                                              color: context.primary)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedUserId = s.userId;
                                        });
                                      },
                                    );
                                  },
                                ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedUserId == null
                        ? null
                        : () {
                            widget.onAdd(
                                _selectedUserId!, _selectedRoleFilter);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                    ),
                    child: Text(AppStrings.addToClinicSameRole,
                        style: AppTextStyles.bodyMedium(context)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<StaffEntity> _filterStaff(List<StaffEntity> allStaff) {
    final seenUserIds = <String>{};
    return allStaff.where((s) {
      if (s.clinicId == widget.clinicId) return false;
      if (s.role != _selectedRoleFilter) return false;
      if (seenUserIds.contains(s.userId)) return false;
      seenUserIds.add(s.userId);
      return true;
    }).toList();
  }
}
