import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';

/// نموذج بيانات الموظف المدعو (Mock)
class InvitedStaffItem {
  final String email;
  final StaffRoles role;

  const InvitedStaffItem({
    required this.email,
    required this.role,
  });

  /// الحرف الأول من البريد الإلكتروني لعرضه في الأيقونة
  String get initial => email.isNotEmpty ? email[0].toUpperCase() : '?';
}

/// ويدجت لعرض قائمة الموظفين المدعوين مع إمكانية الحذف
/// كل عنصر يعرض: أيقونة الحرف الأول + البريد + الصلاحية + زر حذف
class InvitedStaffList extends StatelessWidget {
  final List<InvitedStaffItem> items;
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
        // عنوان القسم مع عدد المدعوين
        Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
          child: Text(
            'المدعوين (${items.length})',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // قائمة المدعوين
        ...List.generate(items.length, (index) {
          final item = items[index];
          return _buildStaffCard(context, item, index);
        }),
      ],
    );
  }

  /// بناء بطاقة موظف مدعو واحد
  Widget _buildStaffCard(
      BuildContext context, InvitedStaffItem item, int index) {
    // تلوين الأيقونة بناءً على الفهرس (تبادل بين primary و neutral)
    final bool isPrimary = index % 2 == 0;
    final Color avatarBg =
        isPrimary ? AppColors.primaryLight : AppColors.surfaceContainerLow;
    final Color avatarColor =
        isPrimary ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceXs),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // أيقونة الحرف الأول
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.initial,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    color: avatarColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),

            // البريد الإلكتروني والصلاحية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // البريد بالإنجليزية (LTR)
                  Text(
                    item.email,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 2),
                  // الصلاحية مع أيقونة
                  Row(
                    children: [
                      Icon(
                        item.role.icon,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.role.label,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // زر الحذف
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => onRemove(index),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
