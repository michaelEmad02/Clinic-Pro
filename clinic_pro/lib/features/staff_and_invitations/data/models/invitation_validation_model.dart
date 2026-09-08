// ────────────────────────────────────────────────────────
// نموذج استجابة التحقق من قيود الدعوة (InvitationValidationModel)
// ────────────────────────────────────────────────────────

import '../../domain/entities/invitation_validation_entity.dart';

class InvitationValidationModel extends InvitationValidationEntity {
  const InvitationValidationModel({
    required super.canInvite,
    super.errorMessage,
    super.isExistingUser = false,
    super.existingName,
    super.existingRole,
  });

  factory InvitationValidationModel.fromJson(Map<String, dynamic> json) {
    return InvitationValidationModel(
      canInvite: json['can_invite'] as bool? ?? true,
      errorMessage: json['error_message'] as String?,
      isExistingUser: json['is_existing_user'] as bool? ?? false,
      existingName: json['existing_name'] as String?,
      existingRole: json['existing_role'] as String?,
    );
  }
}
