import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../domain/entities/clinic_report_entity.dart';
import '../../domain/usecases/get_clinic_report_usecase.dart';

abstract class ClinicReportsState extends Equatable {
  const ClinicReportsState();
  @override
  List<Object?> get props => [];
}

class ClinicReportsInitial extends ClinicReportsState {}

class ClinicReportsLoading extends ClinicReportsState {}

class ClinicReportsLoaded extends ClinicReportsState {
  final ClinicReportEntity report;

  const ClinicReportsLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ClinicReportsError extends ClinicReportsState {
  final String message;

  const ClinicReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

@injectable
class ClinicReportsCubit extends Cubit<ClinicReportsState> {
  final GetClinicReportUseCase _getClinicReportUseCase;

  ClinicReportsCubit(this._getClinicReportUseCase) : super(ClinicReportsInitial());

  Future<void> loadReport(String ownerId, {bool forceRefresh = false}) async {
    if (!forceRefresh && state is ClinicReportsLoaded) return;

    emit(ClinicReportsLoading());
    final result = await _getClinicReportUseCase(ownerId, forceRefresh: forceRefresh);
    result.fold(
      (failure) => emit(ClinicReportsError(AppStrings.loadReportsFailed)),
      (report) => emit(ClinicReportsLoaded(report)),
    );
  }

  void clear() {
    emit(ClinicReportsInitial());
  }
}
