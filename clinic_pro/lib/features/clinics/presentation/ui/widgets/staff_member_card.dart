import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class StaffMemberCard extends StatelessWidget {
  final String name;
  final String displaySpecialty;
  final String? avatarUrl;
  final double rating;
  final String initials;
  final String staffEntryId;
  final VoidCallback onRemove;

  const StaffMemberCard({
    super.key,
    required this.name,
    required this.displaySpecialty,
    this.avatarUrl,
    required this.rating,
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        initials,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                name,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                ),
                child: Text(
                  displaySpecialty,
                  style: AppTextStyles.labelChip(context).copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              if (rating > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star,
                        size: AppConstants.iconSizeSm, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: AppColors.warningText,
                      ),
                    ),
                  ],
                ),
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
                child: const Icon(
                  Icons.remove_circle,
                  color: AppColors.danger,
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
