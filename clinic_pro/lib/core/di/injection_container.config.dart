// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/appointments/presentation/manager/appointments_bloc.dart'
    as _i780;
import '../../features/appointments/presentation/manager/appointments_repository.dart'
    as _i1070;
import '../../features/appointments/presentation/manager/waiting_queue_cubit.dart'
    as _i562;
import '../../features/auth/presentation/manager/auth_cubit.dart' as _i888;
import '../../features/dashboard/presentation/manager/owner_dashboard_cubit.dart'
    as _i456;
import '../../features/expenses/presentation/manager/expenses_cubit.dart'
    as _i560;
import '../../features/expenses/presentation/manager/expenses_repository.dart'
    as _i490;
import '../../features/invoices/presentation/manager/invoices_cubit.dart'
    as _i795;
import '../../features/invoices/presentation/manager/invoices_repository.dart'
    as _i317;
import '../../features/onboarding/presentation/manager/onboarding_cubit.dart'
    as _i1012;
import '../../features/patients/presentation/manager/patients_cubit.dart'
    as _i296;
import '../../features/patients/presentation/manager/patients_repository.dart'
    as _i603;
import '../../features/prescription/presentation/manager/drugs_cubit.dart'
    as _i1042;
import '../../features/prescription/presentation/manager/prescription_bloc.dart'
    as _i329;
import '../../features/prescription/presentation/manager/templates_cubit.dart'
    as _i534;
import '../../features/reports/presentation/manager/reports_cubit.dart'
    as _i600;
import '../../features/reports/presentation/manager/reports_repository.dart'
    as _i985;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/presentation/manager/queue_pattern_cubit.dart'
    as _i467;
import '../../features/settings/presentation/manager/settings_cubit.dart'
    as _i709;
import '../services/i_cloud_service.dart' as _i239;
import '../services/mock_cloud_service.dart' as _i9;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i1012.OnboardingCubit>(() => _i1012.OnboardingCubit());
    gh.lazySingleton<_i239.ICloudService>(() => _i9.MockCloudService());
    gh.lazySingleton<_i657.ISettingsRepository>(
        () => _i955.SettingsRepositoryImpl(gh<_i239.ICloudService>()));
    gh.factory<_i888.AuthCubit>(
        () => _i888.AuthCubit(gh<_i239.ICloudService>()));
    gh.factory<_i456.OwnerDashboardCubit>(
        () => _i456.OwnerDashboardCubit(gh<_i239.ICloudService>()));
    gh.factory<_i1042.DrugsCubit>(
        () => _i1042.DrugsCubit(gh<_i239.ICloudService>()));
    gh.factory<_i534.TemplatesCubit>(
        () => _i534.TemplatesCubit(gh<_i239.ICloudService>()));
    gh.factory<_i467.QueuePatternCubit>(
        () => _i467.QueuePatternCubit(gh<_i239.ICloudService>()));
    gh.factory<_i1070.AppointmentsRepository>(
        () => _i1070.AppointmentsRepository(gh<_i239.ICloudService>()));
    gh.factory<_i490.ExpensesRepository>(
        () => _i490.ExpensesRepository(gh<_i239.ICloudService>()));
    gh.factory<_i317.InvoicesRepository>(
        () => _i317.InvoicesRepository(gh<_i239.ICloudService>()));
    gh.factory<_i603.PatientsRepository>(
        () => _i603.PatientsRepository(gh<_i239.ICloudService>()));
    gh.factory<_i985.ReportsRepository>(
        () => _i985.ReportsRepository(gh<_i239.ICloudService>()));
    gh.factory<_i780.AppointmentsBloc>(
        () => _i780.AppointmentsBloc(gh<_i1070.AppointmentsRepository>()));
    gh.factory<_i562.WaitingQueueCubit>(
        () => _i562.WaitingQueueCubit(gh<_i1070.AppointmentsRepository>()));
    gh.factory<_i560.ExpensesCubit>(
        () => _i560.ExpensesCubit(gh<_i490.ExpensesRepository>()));
    gh.factory<_i329.PrescriptionBloc>(
        () => _i329.PrescriptionBloc(gh<_i239.ICloudService>()));
    gh.factory<_i600.ReportsCubit>(
        () => _i600.ReportsCubit(gh<_i985.ReportsRepository>()));
    gh.factory<_i709.SettingsCubit>(
        () => _i709.SettingsCubit(gh<_i657.ISettingsRepository>()));
    gh.factory<_i795.InvoicesCubit>(
        () => _i795.InvoicesCubit(gh<_i317.InvoicesRepository>()));
    gh.factory<_i296.PatientsCubit>(
        () => _i296.PatientsCubit(gh<_i603.PatientsRepository>()));
    return this;
  }
}
