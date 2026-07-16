import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/clinic_entity.dart';

class ClinicCardHeader extends StatelessWidget {
  final ClinicEntity clinic;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const ClinicCardHeader({
    super.key,
    required this.clinic,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogo(context),
        const SizedBox(width: AppConstants.spaceSm + 4),
        _buildNameAndAddress(context),
        const SizedBox(width: AppConstants.spaceXs),
        _buildPopupMenu(context),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: AppConstants.avatarSizeSm,
      height: AppConstants.avatarSizeSm,
      decoration: BoxDecoration(
        color: clinic.isActive
            ? context.primaryLightColor
            : context.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      ),
      child: clinic.logoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              child: Image.network(
                clinic.logoUrl,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: Text(
                clinic.initials,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: clinic.isActive
                      ? context.textPrimary
                      : context.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }

  Widget _buildNameAndAddress(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  clinic.name,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: clinic.isActive
                        ? context.textPrimary
                        : context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!clinic.isActive) ...[
                const SizedBox(width: AppConstants.spaceSm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                  ),
                  child: Text(
                    AppStrings.disabled,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: context.danger,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: AppConstants.iconSizeSm, color: context.textSecondary),
              const SizedBox(width: AppConstants.spaceXs),
              Flexible(
                child: Text(
                  clinic.address,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'toggleActive':
            onToggleActive();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: context.primary),
            title: Text(AppStrings.editData),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'toggleActive',
          child: ListTile(
            leading: Icon(
              clinic.isActive ? Icons.block : Icons.check_circle_outline,
              color: clinic.isActive ? context.warning : context.successText,
            ),
            title: Text(clinic.isActive
                ? AppStrings.disableClinic
                : AppStrings.enableClinic),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: context.danger),
            title: Text(AppStrings.deleteClinic),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert,
        color: clinic.isActive
            ? context.textSecondary
            : context.textSecondary.withOpacity(0.5),
      ),
    );
  }
}
