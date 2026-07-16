import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class CancelInvitationUseCase {
  final StaffRepository staffRepository;

  CancelInvitationUseCase({required this.staffRepository});

  Future<Either<Failure, void>> call(String invitationId) {
    return staffRepository.cancelInvitation(invitationId);
  }
}
