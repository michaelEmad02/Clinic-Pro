// ────────────────────────────────────────────────────────
// ويدجت قسم الحساب في صفحة الإعدادات (SettingsAccountSection)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

enum AccountSectionLayout { centered, horizontal }

class SettingsAccountSection extends StatelessWidget {
  final String name;
  final String email;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onEdit;
  final AccountSectionLayout layout;
  final String? roleBadge;
  final bool showSectionTitle;

  const SettingsAccountSection({
    super.key,
    required this.name,
    required this.email,
    required this.subtitle,
    this.avatarUrl,
    this.onEdit,
    this.layout = AccountSectionLayout.horizontal,
    this.roleBadge,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final firstChar = name.isNotEmpty ? name[0] : '?';

    Widget content;
    if (layout == AccountSectionLayout.centered) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: context.primaryLightColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: context.primaryLightColor,
                  backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
                  child: !hasAvatar
                      ? Text(
                          firstChar,
                          style: AppTextStyles.headlineMedium(context)
                              .copyWith(color: context.primary, fontSize: 28),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.surfaceColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(name,
              style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold, color: context.textPrimary)),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold, color: context.textSecondary),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 4),
          ],
          if (roleBadge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
              ),
              child: Text(
                roleBadge!,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.spaceMd),
          OutlinedButton.icon(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
            icon: Icon(Icons.person_outline,
                size: 20, color: context.primary),
            label: Text(
              AppStrings.editProfile,
              style: AppTextStyles.bodyLarge(context).copyWith(
                  color: context.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    } else {
      // Horizontal layout
      content = Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.primaryLightColor,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
            child: !hasAvatar
                ? Text(
                    firstChar,
                    style: AppTextStyles.headlineMedium(context)
                        .copyWith(color: context.primary),
                  )
                : null,
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineSmall(context)),
                const SizedBox(height: 2),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(color: context.textSecondary),
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            label: Text(
              AppStrings.editProfileShort,
              style: AppTextStyles.bodyLarge(context)
                  .copyWith(color: context.primary),
            ),
            icon: Icon(Icons.arrow_back,
                color: context.primary, size: 18),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSectionTitle) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
            child: Text(
              AppStrings.account,
              style: AppTextStyles.headlineSmall(context)
                  .copyWith(color: context.textSecondary),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.borderColor, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: content,
        ),
      ],
    );
  }
}
