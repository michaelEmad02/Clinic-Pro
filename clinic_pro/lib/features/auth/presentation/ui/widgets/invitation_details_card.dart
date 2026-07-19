// ────────────────────────────────────────────────────────
// كارت عرض تفاصيل الدعوة (InvitationDetailsCard)
// يعرض: اسم العيادة، الدور، اسم المدعو، تاريخ الانتهاء
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../staff/domain/entities/invitation_entity.dart';

class InvitationDetailsCard extends StatelessWidget {
  final InvitationEntity invitation;

  const InvitationDetailsCard({super.key, required this.invitation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // أيقونة الدعوة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:  Icon(
              Icons.mark_email_read_rounded,
              size: 48,
              color: context.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // عنوان الدعوة
          Text(
            'دعوة للانضمام',
            style: AppTextStyles.headlineMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceXs),

          Text(
            'تمت دعوتك للانضمام إلى فريق العمل',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // تفاصيل الدعوة
          _buildDetailRow(
            context,
            icon: Icons.local_hospital_rounded,
            label: 'العيادة',
            value: invitation.clinicName ?? 'غير محدد',
          ),
          const SizedBox(height: AppConstants.spaceSm),

          _buildDetailRow(
            context,
            icon: Icons.badge_rounded,
            label: 'الدور',
            value: _getRoleDisplayName(invitation.role),
          ),
          const SizedBox(height: AppConstants.spaceSm),

          if (invitation.name != null && invitation.name!.isNotEmpty) ...[
            _buildDetailRow(
              context,
              icon: Icons.person_rounded,
              label: 'الاسم',
              value: invitation.name!,
            ),
            const SizedBox(height: AppConstants.spaceSm),
          ],

          // الطبيب المرتبط (للسكرتير فقط)
          if (invitation.role == StaffRoles.secretary &&
              invitation.doctorName != null) ...[
            _buildDetailRow(
              context,
              icon: Icons.medical_services_rounded,
              label: 'الطبيب',
              value: invitation.doctorName!,
            ),
            const SizedBox(height: AppConstants.spaceSm),
          ],

          _buildDetailRow(
            context,
            icon: Icons.timer_rounded,
            label: 'تنتهي في',
            value: _formatDate(invitation.expiredAt),
            valueColor: _isExpiringSoon(invitation.expiredAt)
                ? context.warning
                : null,
          ),
        ],
      ),
    );
  }

  /// بناء صف تفاصيل واحد
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusInput),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.primary),
          const SizedBox(width: AppConstants.spaceSm),
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// تحويل الدور لاسم معروض بالعربية
  String _getRoleDisplayName(StaffRoles role) {
    switch (role) {
      case StaffRoles.doctor:
        return 'طبيب';
      case StaffRoles.secretary:
        return 'سكرتير';
      case StaffRoles.owner:
        return 'مالك';
    }
  }

  /// تنسيق التاريخ للعرض
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// التحقق إذا كانت الدعوة قريبة من الانتهاء (أقل من يومين)
  bool _isExpiringSoon(DateTime expiresAt) {
    return expiresAt.difference(DateTime.now()).inDays < 2;
  }
}
