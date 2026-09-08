// ────────────────────────────────────────────────────────
// كينونة نتيجة التحقق من صلاحية دعوة الموظف (Validation Result)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// تمثل نتيجة فحص القيود المفروضة على دعوة الموظف قبل إرسالها
class InvitationValidationEntity extends Equatable {
  final bool canInvite;
  final String? errorMessage;
  final bool isExistingUser;
  final String? existingName;
  final String? existingRole;

  const InvitationValidationEntity({
    required this.canInvite,
    this.errorMessage,
    this.isExistingUser = false,
    this.existingName,
    this.existingRole,
  });

  @override
  List<Object?> get props => [
        canInvite,
        errorMessage,
        isExistingUser,
        existingName,
        existingRole,
      ];
}
