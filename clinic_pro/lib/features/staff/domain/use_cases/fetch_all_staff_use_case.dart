import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/staff/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class FetchAllStaffUseCase {
  final StaffRepository staffRepository;

  FetchAllStaffUseCase({required this.staffRepository});

  Future<Either<Failure, List<StaffEntity>>> call(String ownerId) {
    return staffRepository.fetchAllStaff(ownerId);
  }
}
