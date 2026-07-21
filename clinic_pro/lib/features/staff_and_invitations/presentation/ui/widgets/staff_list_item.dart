// ────────────────────────────────────────────────────────
// بطاقة موظف في Grid — مطابقة لتصميم phase8_ui/staff_screen
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class StaffListItem extends StatelessWidget {
  final StaffEntity staff;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final String? clinicName;

  const StaffListItem({
    super.key,
    required this.staff,
    required this.onTap,
    required this.onMore,
    this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    final specialtyLabel = staff.specialty ?? staff.role.label;

    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.border),
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
                        backgroundColor: context.primaryLightColor,
                        backgroundImage: staff.avatarUrl != null
                            ? NetworkImage(staff.avatarUrl!)
                            : null,
                        child: staff.avatarUrl == null
                            ? Text(
                                staff.initials,
                                style: AppTextStyles.headlineSmall(context)
                                    .copyWith(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
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
                          style: AppTextStyles.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialtyLabel,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
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
                      icon: Icon(Icons.more_vert,
                          size: 18, color: context.textSecondary),
                      onPressed: onMore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // شارة الدور
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildRoleBadge(context),
                  const SizedBox(width: 15),
                  if (clinicName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.business,
                            size: 14, color: context.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          clinicName!,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // const SizedBox(height: 12),
              // // خط فاصل
              // Divider(height: 1, color: context.border),
              // const SizedBox(height: 8),
              // // صف الحالة + رابط عرض الملف
              // Row(
              //   children: [
              //     Text(
              //       AppStrings.viewProfile,
              //       style: AppTextStyles.labelChip(context).copyWith(
              //         color: context.primary,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
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

    if (staff.role == StaffRoles.secretary) {
      bg = context.primaryLightColor;
      text = context.primary;
      icon = Icons.medical_services;
      label = StaffRoles.secretary.label;
    } else if (staff.role == StaffRoles.doctor) {
      bg = context.successBg;
      text = context.successText;
      icon = Icons.vaccines;
      label = StaffRoles.doctor.label;
    } else {
      bg = context.surfaceContainerLow;
      text = context.textSecondary;
      icon = Icons.person;
      label = staff.role.label;
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
class StatusDot extends StatelessWidget {
  final bool isOnline;
  const StatusDot({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isOnline ? context.successText : context.outline,
        shape: BoxShape.circle,
        border: Border.all(color: context.surface, width: 2),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: context.successText.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
