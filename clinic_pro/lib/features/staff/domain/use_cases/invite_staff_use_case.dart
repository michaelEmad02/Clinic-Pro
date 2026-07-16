import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:clinic_pro/features/staff/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class InviteStaffUseCase {
  final StaffRepository staffRepository;

  InviteStaffUseCase({required this.staffRepository});

  Future<Either<Failure, void>> call(InvitationEntity staff) {
    return staffRepository.inviteStaff(staff);
  }
}
