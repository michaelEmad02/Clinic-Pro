import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, String>> addClinic(ExpensesEntity expenses);
  Future<Either<Failure, void>> editClinic(ClinicEntity clinic);
  Future<Either<Failure, void>> deleteClinic(String id);
 
}
