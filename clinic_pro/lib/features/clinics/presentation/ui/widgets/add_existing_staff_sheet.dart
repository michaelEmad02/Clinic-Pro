import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../staff_and_invitations/domain/entities/staff_entity.dart';
import '../../../../staff_and_invitations/presentation/manager/staff_cubit.dart';
import '../../../../staff_and_invitations/presentation/manager/staff_state.dart';
/// قائمة الأطباء في العيادة الحالية (تُمرر من الخارج)
class AddExistingStaffSheet extends StatefulWidget {
  final String clinicId;
  final List<StaffEntity> clinicDoctors;
  // onAdd تم تحديثها لتشمل doctorId اختياري (للسكرتير)
  final Future<void> Function(String userId, StaffRoles role, String? doctorId) onAdd;

  const AddExistingStaffSheet({
    super.key,
    required this.clinicId,
    required this.clinicDoctors,
    required this.onAdd,
  });

  @override
  State<AddExistingStaffSheet> createState() => _AddExistingStaffSheetState();
}

class _AddExistingStaffSheetState extends State<AddExistingStaffSheet> {
  String? _selectedUserId;
  String? _selectedDoctorId;
  StaffRoles _selectedRoleFilter = StaffRoles.doctor;

  /// هل الدور المختار يتطلب اختيار طبيب مرتبط
  bool get _needsDoctorSelection =>
      _selectedRoleFilter == StaffRoles.secretary;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final ownerId = authState.user?.id ?? '';

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
                // ── العنوان ──
                Text(
                  AppStrings.existingMember,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // ── فلترة حسب الدور ──
                _buildRoleFilter(context),
                const SizedBox(height: AppConstants.spaceMd),

                // ── قائمة الأعضاء المتاحين ──
                _buildMembersList(context, state, otherStaff),

                // ── اختيار الطبيب المرتبط (للسكرتير فقط) ──
                if (_needsDoctorSelection && _selectedUserId != null) ...[
                  const SizedBox(height: AppConstants.spaceMd),
                  _buildDoctorSelection(context, widget.clinicDoctors),
                ],

                const SizedBox(height: AppConstants.spaceLg),

                // ── زر الإضافة ──
                _buildAddButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// عرض chips لتصفية الأدوار
  Widget _buildRoleFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                        _selectedDoctorId = null;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// عرض قائمة الأعضاء المتاحين حسب الفلتر
  Widget _buildMembersList(
      BuildContext context, StaffState state, List<StaffEntity> otherStaff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                                  .copyWith(color: context.textSecondary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: otherStaff.length,
                          itemBuilder: (ctx, idx) {
                            final s = otherStaff[idx];
                            final isSelected = _selectedUserId == s.userId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? context.primaryLightColor
                                    : context.surfaceContainerLow,
                                child: Text(s.name.substring(0, 1)),
                              ),
                              title: Text(s.name,
                                  style: AppTextStyles.bodyMedium(context)),
                              subtitle: Text(s.specialty ?? '',
                                  style: AppTextStyles.caption(context)),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: context.primary)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedUserId = s.userId;
                                  _selectedDoctorId = null;
                                });
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }

  /// عرض اختيار الطبيب المرتبط (يظهر فقط عند اختيار سكرتير)
  Widget _buildDoctorSelection(
      BuildContext context, List<StaffEntity> clinicDoctors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectAssociatedDoctor,
          style: AppTextStyles.bodyMedium(context)
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        if (clinicDoctors.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
            child: Text(
              AppStrings.noDoctorsAvailable,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(color: context.textSecondary),
            ),
          )
        else
          // قائمة الأطباء المتاحين في العيادة
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: clinicDoctors.length,
              itemBuilder: (ctx, idx) {
                final doctor = clinicDoctors[idx];
                final isSelected = _selectedDoctorId == doctor.userId;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected
                        ? context.accent
                        : context.surfaceContainerLow,
                    child: Text(
                      doctor.name.substring(0, 1),
                      style: AppTextStyles.caption(context).copyWith(
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                  title: Text(doctor.name,
                      style: AppTextStyles.bodyMedium(context)),
                  subtitle: Text(doctor.specialty ?? '',
                      style: AppTextStyles.caption(context)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: context.accent)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDoctorId = doctor.userId;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  /// زر الإضافة — يتطلب اختيار طبيب إذا كان الدور سكرتير
  Widget _buildAddButton(BuildContext context) {
    final isEnabled = _selectedUserId != null &&
        (!_needsDoctorSelection || _selectedDoctorId != null);

    return SizedBox(
      width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () async {
                  await widget.onAdd(
                    _selectedUserId!,
                    _selectedRoleFilter,
                    _needsDoctorSelection ? _selectedDoctorId : null,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.onPrimary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  AppStrings.addToClinicSameRole,
                  style: AppTextStyles.bodyMedium(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
    );
  }

  /// تصفية الموظفين: إزالة الموجودين في نفس العيادة + حسب الدور المختار
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
