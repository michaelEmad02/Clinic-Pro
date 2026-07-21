import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/staff_and_invitations/data/data_sources/staff_remote_data_source.dart';
import 'package:clinic_pro/features/staff_and_invitations/data/models/invitation_model.dart';
import 'package:clinic_pro/features/staff_and_invitations/data/models/staff_model.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/invitation_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@LazySingleton(as: StaffRepository)
class StaffRepoImplementation extends StaffRepository {
  final StaffRemoteDataSource staffRemoteDataSource;

  StaffRepoImplementation({required this.staffRemoteDataSource});
  @override
  Future<Either<Failure, void>> deleteStaff(String staffId) async {
    try {
      await staffRemoteDataSource.deleteStaff(staffId);
      return right(null);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> editStaff(StaffEntity staff) async {
    try {
      await staffRemoteDataSource.editStaff(StaffModel(
          id: staff.id,
          clinicId: staff.clinicId,
          userId: staff.userId,
          name: staff.name,
          email: staff.email,
          phone: staff.phone,
          avatarUrl: staff.avatarUrl,
          specialty: staff.specialty,
          role: staff.role,
          isActive: staff.isActive,
          joinedAt: staff.joinedAt));
      return right(null);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<StaffEntity>>> fetchAllStaff(
      String ownerId) async {
    try {
      var result = await staffRemoteDataSource.fetchAllStaff(ownerId);
      return right(result);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<InvitationEntity>>> fetchPendingInvitations(
      String ownerId) async {
    try {
      var result = await staffRemoteDataSource.fetchPendingInvitations(ownerId);
      return right(result);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> fetchStaffById(String id) async {
    try {
      var result = await staffRemoteDataSource.fetchStaffById(id);
      return right(result);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> inviteStaff(InvitationEntity staff) async {
    try {
      await staffRemoteDataSource.inviteStaff(InvitationModel(
          id: staff.id,
          ownerId: staff.ownerId,
          clinicId: staff.clinicId,
          email: staff.email,
          name: staff.name,
          role: staff.role,
          token: staff.token,
          status: staff.status,
          expiredAt: staff.expiredAt,
          createdAt: staff.createdAt));
      return right(null);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvitation(String invitationId) async {
    try {
      await staffRemoteDataSource.cancelInvitation(invitationId);
      return right(null);
    } catch (e) {
      return left(QueryFailure.fromException(e));
    }
  }
}
