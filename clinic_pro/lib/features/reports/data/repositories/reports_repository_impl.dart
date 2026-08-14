import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/entities/clinic_report_entity.dart';
import '../../domain/repositories/i_reports_repository.dart';
import '../datasources/i_reports_remote_data_source.dart';

import 'package:flutter/material.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';

@LazySingleton(as: IReportsRepository)
class ReportsRepositoryImpl implements IReportsRepository {
  final IReportsRemoteDataSource _remoteDataSource;

  ReportsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, RevenueSummaryEntity>> getRevenueSummary({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _remoteDataSource.fetchRevenueSummary(
        doctorId: doctorId,
        clinicId: clinicId,
        range: range,
        customDateRange: customDateRange,
        forceRefresh: forceRefresh,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentStatsEntity>> getAppointmentStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _remoteDataSource.fetchAppointmentStats(
        doctorId: doctorId,
        clinicId: clinicId,
        range: range,
        customDateRange: customDateRange,
        forceRefresh: forceRefresh,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientStatsEntity>> getPatientStats({
    String? doctorId,
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _remoteDataSource.fetchPatientStats(
        doctorId: doctorId,
        clinicId: clinicId,
        range: range,
        customDateRange: customDateRange,
        forceRefresh: forceRefresh,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorPerformanceEntity>>> getDoctorPerformance({
    String? clinicId,
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
    bool forceRefresh = false,
  }) async {
    try {
      final list = await _remoteDataSource.fetchDoctorPerformance(
        clinicId: clinicId,
        range: range,
        customDateRange: customDateRange,
        forceRefresh: forceRefresh,
      );
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DrugStatsEntity>> getDrugStats({
    String? doctorId,
    String? clinicId,
    bool forceRefresh = false,
  }) async {
    try {
      final model = await _remoteDataSource.fetchDrugStats(
        doctorId: doctorId,
        clinicId: clinicId,
        forceRefresh: forceRefresh,
      );
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TemplateStatsEntity>>> getTemplateStats({
    String? doctorId,
    bool forceRefresh = false,
  }) async {
    try {
      final list = await _remoteDataSource.fetchTemplateStats(
        doctorId: doctorId,
        forceRefresh: forceRefresh,
      );
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClinicReportEntity>> getClinicReport(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    try {
      final data = await _remoteDataSource.fetchClinicReport(
        ownerId,
        forceRefresh: forceRefresh,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

