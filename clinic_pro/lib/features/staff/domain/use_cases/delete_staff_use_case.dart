import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class DeleteStaffUseCase {
  final StaffRepository staffRepository;

  DeleteStaffUseCase({required this.staffRepository});

  Future<Either<Failure, void>> call(String staffId) {
    return staffRepository.deleteStaff(staffId);
  }
}
