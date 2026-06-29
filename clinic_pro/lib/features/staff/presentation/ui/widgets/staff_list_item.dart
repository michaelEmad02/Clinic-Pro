// ────────────────────────────────────────────────────────
// بطاقة موظف في Grid — مطابقة لتصميم phase8_ui/staff_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/staff_state.dart';

class StaffListItem extends StatelessWidget {
  final StaffItem staff;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const StaffListItem({
    super.key,
    required this.staff,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final specialtyLabel = staff.specialty ?? staff.roleLabel;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة: الصورة + الاسم والتخصص + زر more
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصورة مع نقطة الحالة
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: staff.avatarUrl != null
                            ? NetworkImage(staff.avatarUrl!)
                            : null,
                        child: staff.avatarUrl == null
                            ? Text(
                                staff.initials,
                                style: AppTextStyles
                                    .headlineSmall(context)
                                    .copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      // نقطة الحالة الخضراء (pulsing anim)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: _StatusDot(isOnline: staff.isOnline),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // الاسم والتخصص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.name,
                          style: AppTextStyles
                              .headlineSmall(context)
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialtyLabel,
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // زر more_vert
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert,
                          size: 18, color: AppColors.textSecondary),
                      onPressed: onMore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // شارة الدور
              _buildRoleBadge(context),
              const SizedBox(height: 12),
              // خط فاصل
              Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 8),
              // صف الحالة + رابط عرض الملف
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          staff.isOnline
                              ? Icons.schedule
                              : Icons.history,
                          size: 14,
                          color: staff.isOnline
                              ? AppColors.successText
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            staff.isOnline
                                ? 'متاح الآن'
                                : (staff.lastSeen ?? 'غير متصل'),
                            style:
                                AppTextStyles.labelChip(context).copyWith(
                              color: staff.isOnline
                                  ? AppColors.successText
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'عرض الملف',
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;
    String label;

    switch (staff.role) {
      case 'doctor':
        bg = AppColors.primaryLight;
        text = AppColors.primary;
        icon = Icons.medical_services;
        label = 'دكتور';
      case 'nurse':
        bg = AppColors.successBg;
        text = AppColors.successText;
        icon = Icons.vaccines;
        label = 'تمريض';
      case 'accountant':
        bg = AppColors.warningBg;
        text = AppColors.warningText;
        icon = Icons.account_balance;
        label = 'محاسب';
      case 'secretary':
        bg = AppColors.surfaceContainerHigh;
        text = AppColors.onSurfaceVariant;
        icon = Icons.admin_panel_settings;
        label = 'إدارة';
      default:
        bg = AppColors.surfaceContainerLow;
        text = AppColors.textSecondary;
        icon = Icons.person;
        label = staff.roleLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelChip(context).copyWith(
              color: text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── نقطة الحالة مع تأثير النبض الأخضر ──
class _StatusDot extends StatelessWidget {
  final bool isOnline;
  const _StatusDot({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.successText : AppColors.outline,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: AppColors.successText.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
