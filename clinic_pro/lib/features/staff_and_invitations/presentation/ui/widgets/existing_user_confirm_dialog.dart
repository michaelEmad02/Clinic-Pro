// ────────────────────────────────────────────────────────
// نافذة تأكيد دعوة مستخدم مسجل مسبقاً في النظام
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ExistingUserConfirmDialog extends StatelessWidget {
  final String userName;
  final String userRole;
  final String clinicName;

  const ExistingUserConfirmDialog({
    super.key,
    required this.userName,
    required this.userRole,
    required this.clinicName,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String userName,
    required String userRole,
    required String clinicName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ExistingUserConfirmDialog(
        userName: userName,
        userRole: userRole,
        clinicName: clinicName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
      ),
      icon: const Icon(
        Icons.info_outline_rounded,
        color: Colors.amber,
        size: 44,
      ),
      title: Text(
        'تنبيه: المستخدم مسجل مسبقاً',
        style: AppTextStyles.headlineSmall(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'المستخدم "$userName" ($userRole) مسجل مسبقاً في النظام.\nهل تريد تأكيد إرسال الدعوة لضمه إلى "$clinicName"؟',
        style: AppTextStyles.bodyMedium(context).copyWith(
          color: context.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
          ),
          child: const Text('تأكيد وإضافة'),
        ),
      ],
    );
  }
}
