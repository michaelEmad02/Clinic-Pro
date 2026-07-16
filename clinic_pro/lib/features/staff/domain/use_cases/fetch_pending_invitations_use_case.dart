import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:clinic_pro/features/staff/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class FetchPendingInvitationsUseCase {
  final StaffRepository staffRepository;

  FetchPendingInvitationsUseCase({required this.staffRepository});

  Future<Either<Failure, List<InvitationEntity>>> call(String ownerId) {
    return staffRepository.fetchPendingInvitations(ownerId);
  }
}
