// ────────────────────────────────────────────────────────
// InvoicesRepositoryImpl — تنفيذ مستودع الفواتير بـ Data Layer
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/invoices/data/data_sources/invoices_remote_data_source.dart';
import 'package:clinic_pro/features/invoices/data/models/invoice_model.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IInvoicesRepository)
class InvoicesRepositoryImpl implements IInvoicesRepository {
  final IInvoicesRemoteDataSource _remoteDataSource;

  InvoicesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getInvoices(
      String clinicId) async {
    try {
      final invoices = await _remoteDataSource.getInvoices(clinicId);
      return Right(invoices);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> createInvoice({
    required String clinicId,
    required String patientId,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
    required String createdBy,
  }) async {
    try {
      final model = InvoiceModel(
        id: '',
        clinicId: clinicId,
        patientId: patientId,
        sourceId: sourceId,
        sourceType: 'appointment',
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod ?? 'cash',
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      await _remoteDataSource.createInvoice(model);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateInvoice(InvoiceEntity invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      await _remoteDataSource.updateInvoice(model);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvoice(String invoiceId) async {
    try {
      await _remoteDataSource.deleteInvoice(invoiceId);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<UnpaidAppointmentEntity>>>
      getPatientUnpaidAppointments(String patientId) async {
    try {
      final appointments =
          await _remoteDataSource.getPatientUnpaidAppointments(patientId);
      return Right(appointments);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}
