import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StaffRepository {
  Future<Either<Failure, List<StaffEntity>>> fetchAllStaff(String ownerId);
  Future<Either<Failure, StaffEntity>> fetchStaffById(String id);
  Future<Either<Failure, void>> inviteStaff(InvitationEntity staff);
  Future<Either<Failure, List<InvitationEntity>>> fetchPendingInvitations(
      String ownerId);
  Future<Either<Failure, void>> editStaff(StaffEntity staff);
  Future<Either<Failure, void>> deleteStaff(String staffId);
  Future<Either<Failure, void>> cancelInvitation(String invitationId);
}
