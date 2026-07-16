import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class StaffMemberCard extends StatelessWidget {
  final String name;
  final String displaySpecialty;
  final String? avatarUrl;
  final String initials;
  final String staffEntryId;
  final VoidCallback onRemove;

  const StaffMemberCard({
    super.key,
    required this.name,
    required this.displaySpecialty,
    this.avatarUrl,
    required this.initials,
    required this.staffEntryId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: context.border),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: context.primaryLightColor,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        initials,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                name,
                style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold, color: context.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                ),
                child: Text(
                  displaySpecialty,
                  style: AppTextStyles.labelChip(context).copyWith(
                    color: context.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceXs),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove_circle,
                  color: context.danger,
                  size: AppConstants.iconSizeLg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
