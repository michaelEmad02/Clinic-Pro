import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/repositories/staff_repository.dart';
import 'package:dartz/dartz.dart';

@injectable
class FetchStaffByIsUseCase {
  final StaffRepository staffRepository;

  FetchStaffByIsUseCase({required this.staffRepository});

  Future<Either<Failure, StaffEntity>> call(String id) {
    return staffRepository.fetchStaffById(id);
  }
}
