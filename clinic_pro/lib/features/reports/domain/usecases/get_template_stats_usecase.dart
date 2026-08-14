import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import '../entities/reports_entities.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetTemplateStatsUseCase {
  final IReportsRepository repository;

  GetTemplateStatsUseCase(this.repository);

  Future<Either<Failure, List<TemplateStatsEntity>>> call({String? doctorId}) {
    return repository.getTemplateStats(doctorId: doctorId);
  }
}
