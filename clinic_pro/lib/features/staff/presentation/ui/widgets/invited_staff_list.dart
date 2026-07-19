import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/strings/app_strings.dart';


class InvitedStaffList extends StatelessWidget {
  final List<InvitationEntity> items;
  final ValueChanged<int> onRemove;

  const InvitedStaffList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
          child: Text(
            AppStrings.inviteesCount(items.length),
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard - 4),
                border: Border.all(color: context.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: context.primaryLightColor,
                    child: Text(
                      item.initial,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? '',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.email,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.role == StaffRoles.doctor
                              ? context.successBg
                              : context.primaryLightColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.role.label,
                          style: AppTextStyles.caption(context).copyWith(
                            color: item.role == StaffRoles.doctor
                                ? context.successText
                                : context.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.clinicName ?? '',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textHint,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: context.danger, size: 20),
                    onPressed: () => onRemove(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
