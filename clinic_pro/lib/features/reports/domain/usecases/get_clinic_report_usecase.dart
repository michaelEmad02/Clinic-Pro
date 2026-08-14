import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/clinic_report_entity.dart';
import '../repositories/i_reports_repository.dart';

@injectable
class GetClinicReportUseCase {
  final IReportsRepository repository;

  GetClinicReportUseCase(this.repository);

  Future<Either<Failure, ClinicReportEntity>> call(
    String ownerId, {
    bool forceRefresh = false,
  }) {
    return repository.getClinicReport(ownerId, forceRefresh: forceRefresh);
  }
}
