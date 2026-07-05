import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';

/// نموذج بيانات الموظف المدعو (Mock)
class InvitedStaffItem {
  final String email;
  final String name;
  final StaffRoles role;
  final String clinicId;
  final String clinicName;
  final String? doctorId;
  final String? doctorName;

  const InvitedStaffItem({
    required this.email,
    required this.name,
    required this.role,
    required this.clinicId,
    required this.clinicName,
    this.doctorId,
    this.doctorName,
  });

  /// الحرف الأول من الاسم لعرضه في الأيقونة
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
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
                    fontWeight: FontWeight.w700,
                    color: avatarColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceSm),

            // الاسم والبريد الإلكتروني والصلاحية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // البريد بالإنجليزية (LTR)
                  Text(
                    item.email,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  // الصلاحية + العيادة + الطبيب
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildBadge(context, item.role.icon, item.role.label),
                      _buildBadge(context, Icons.business_outlined, item.clinicName),
                      if (item.doctorName != null)
                        _buildBadge(context, Icons.person_outline, 'الطبيب: ${item.doctorName}'),
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

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
