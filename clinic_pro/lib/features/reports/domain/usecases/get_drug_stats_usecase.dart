import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/reports_entities.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetDrugStatsUseCase {
  final IReportsRepository repository;

  GetDrugStatsUseCase(this.repository);

  Future<Either<Failure, DrugStatsEntity>> call({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  }) {
    return repository.getDrugStats(
      doctorId: doctorId,
      clinicId: clinicId,
      forceRefresh: forceRefresh,
    );
  }
}
