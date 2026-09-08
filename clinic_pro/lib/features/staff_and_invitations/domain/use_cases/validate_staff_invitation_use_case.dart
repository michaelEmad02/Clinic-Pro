// ────────────────────────────────────────────────────────
// حالة استخدام التحقق من قيود وصلاحية دعوة الموظف
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/invitation_validation_entity.dart';
import '../repositories/staff_repository.dart';

@injectable
class ValidateStaffInvitationUseCase {
  final StaffRepository staffRepository;

  ValidateStaffInvitationUseCase({required this.staffRepository});

  Future<Either<Failure, InvitationValidationEntity>> call({
    required String email,
    required String clinicId,
    required StaffRoles role,
    String? doctorId,
  }) {
    return staffRepository.validateInvitation(
      email: email,
      clinicId: clinicId,
      role: role,
      doctorId: doctorId,
    );
  }
}
