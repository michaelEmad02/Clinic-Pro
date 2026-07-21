import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class EditStaffEntityUseCase {
  final StaffRepository staffRepository;

  EditStaffEntityUseCase({required this.staffRepository});

  Future<Either<Failure, void>> call(StaffEntity staff) {
    return staffRepository.editStaff(staff);
  }
}
