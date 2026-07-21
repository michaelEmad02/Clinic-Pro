// ────────────────────────────────────────────────────────
// قسم الدعوات المعلقة — مطابقة لتصميم phase8_ui/staff_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/invitation_entity.dart';

class PendingInvitationsSection extends StatelessWidget {
  final List<InvitationEntity> invitations;
  final ValueChanged<InvitationEntity> onResend;
  final ValueChanged<InvitationEntity> onCancel;

  const PendingInvitationsSection({
    super.key,
    required this.invitations,
    required this.onResend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.pending_actions, size: 20, color: context.warningText),
              const SizedBox(width: 6),
              Text(
                AppStrings.pendingInvitations,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.warningText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${invitations.length}',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    color: context.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: invitations.map((inv) {
                  return SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - 8) / 2
                        : constraints.maxWidth,
                    child: _InvitationCard(
                      invitation: inv,
                      onResend: () => onResend(inv),
                      onCancel: () => onCancel(inv),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationEntity invitation;
  final VoidCallback onResend;
  final VoidCallback onCancel;

  const _InvitationCard({
    required this.invitation,
    required this.onResend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة البريد
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.warningBg,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.mail_outline, color: context.warningText, size: 20),
          ),
          const SizedBox(width: 12),
          // البريد الإلكتروني + الدور
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.email,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 2),
                Text(
                  invitation.role.label,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // أزرار الإجراءات
          const SizedBox(width: 8),
          InkWell(
            onTap: onResend,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh, size: 18, color: context.primary),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onCancel,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.dangerBg,
                shape: BoxShape.circle,
              ),
              child:
                   Icon(Icons.close, size: 18, color: context.dangerText),
            ),
          ),
        ],
      ),
    );
  }
}
