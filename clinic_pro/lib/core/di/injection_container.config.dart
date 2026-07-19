// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:clinic_pro/core/services/supabase_services.dart';
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/appointments/presentation/manager/appointments_bloc.dart'
    as _i780;
import '../../features/appointments/presentation/manager/appointments_repository.dart'
    as _i1070;
import '../../features/appointments/presentation/manager/waiting_queue_cubit.dart'
    as _i562;
import '../../features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i25;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/i_auth_repository.dart'
    as _i589;
import '../../features/auth/domain/use_cases/accept_invitation_use_case.dart'
    as _i730;
import '../../features/auth/domain/use_cases/get_current_user_use_case.dart'
    as _i129;
import '../../features/auth/domain/use_cases/get_invitation_by_token_use_case.dart'
    as _i1051;
import '../../features/auth/domain/use_cases/is_email_verified_use_case.dart'
    as _i619;
import '../../features/auth/domain/use_cases/login_with_apple_use_case.dart'
    as _i652;
import '../../features/auth/domain/use_cases/login_with_email_and_password_use_case.dart'
    as _i394;
import '../../features/auth/domain/use_cases/login_with_google_use_case.dart'
    as _i490;
import '../../features/auth/domain/use_cases/logout_use_case.dart' as _i698;
import '../../features/auth/domain/use_cases/register_owner_use_case.dart'
    as _i488;
import '../../features/auth/domain/use_cases/send_magic_link_use_case.dart'
    as _i695;
import '../../features/auth/domain/use_cases/verify_email_use_case.dart'
    as _i421;
import '../../features/auth/presentation/manager/accept_invitation_cubit.dart'
    as _i189;
import '../../features/auth/presentation/manager/auth_cubit.dart' as _i888;
import '../../features/clinics/data/data_sources/clinics_remote_data_source.dart'
    as _i256;
import '../../features/clinics/data/repositories/clinics_repo_implementation.dart'
    as _i0;
import '../../features/clinics/domain/repositories/clinics_repository.dart'
    as _i359;
import '../../features/clinics/domain/use_cases/add_clinic_use_case.dart'
    as _i747;
import '../../features/clinics/domain/use_cases/add_staff_use_case.dart'
    as _i25;
import '../../features/clinics/domain/use_cases/delete_clinic_use_case.dart'
    as _i2;
import '../../features/clinics/domain/use_cases/delete_staff_use_case.dart'
    as _i542;
import '../../features/clinics/domain/use_cases/edit_clinic_use_case.dart'
    as _i240;
import '../../features/clinics/domain/use_cases/fetch_clinic_by_id_use_case.dart'
    as _i665;
import '../../features/clinics/domain/use_cases/fetch_clinic_staff_use_case.dart'
    as _i468;
import '../../features/clinics/domain/use_cases/fetch_clinic_statistics_use_case.dart'
    as _i143;
import '../../features/clinics/domain/use_cases/fetch_clinics_use_case.dart'
    as _i236;
import '../../features/clinics/domain/use_cases/toggle_is_active_use_case.dart'
    as _i444;
import '../../features/clinics/presentation/manager/cubit/clinics_cubit.dart'
    as _i169;
import '../../features/clinics/presentation/manager/cubit/fetch_clinic_by_id_cubit.dart'
    as _i317;
import '../../features/clinics/presentation/manager/cubit/fetch_clinic_staff_cubit.dart'
    as _i750;
import '../../features/clinics/presentation/manager/cubit/fetch_clinic_statistics_cubit.dart'
    as _i728;
import '../../features/dashboard/presentation/manager/owner_dashboard_cubit.dart'
    as _i456;
import '../../features/dashboard/presentation/manager/secretary_dashboard_cubit.dart'
    as _i158;
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
import '../../features/staff/data/data_sources/staff_remote_data_source.dart'
    as _i322;
import '../../features/staff/data/repositories/staff_repo_implementation.dart'
    as _i511;
import '../../features/staff/domain/repositories/staff_repository.dart'
    as _i841;
import '../../features/staff/domain/use_cases/cancel_invitation_use_case.dart'
    as _i929;
import '../../features/staff/domain/use_cases/delete_staff_use_case.dart'
    as _i801;
import '../../features/staff/domain/use_cases/edit_staff_entity_use_case.dart'
    as _i787;
import '../../features/staff/domain/use_cases/fetch_all_staff_use_case.dart'
    as _i756;
import '../../features/staff/domain/use_cases/fetch_pending_invitations_use_case.dart'
    as _i366;
import '../../features/staff/domain/use_cases/fetch_staff_by_is_use_case.dart'
    as _i445;
import '../../features/staff/domain/use_cases/invite_staff_use_case.dart'
    as _i358;
import '../../features/staff/presentation/manager/invite_staff_cubit.dart'
    as _i165;
import '../../features/staff/presentation/manager/staff_cubit.dart' as _i441;
import '../localization/language_cubit.dart' as _i170;
import '../services/i_auth_services.dart' as _i662;
import '../services/i_cloud_service.dart' as _i239;
import '../services/mock_cloud_service.dart' as _i9;
import '../services/supabase_auth_services.dart' as _i693;
import '../themes/theme_cubit.dart' as _i965;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.factory<_i1012.OnboardingCubit>(() => _i1012.OnboardingCubit());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabase);
    gh.lazySingleton<_i170.LanguageCubit>(
        () => _i170.LanguageCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i965.ThemeCubit>(
        () => _i965.ThemeCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i239.ICloudService>(() => _i9.MockCloudService());
    gh.lazySingleton<_i662.IAuthServices>(
        () => _i693.SupabaseAuthServices(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i256.IClinicsRemoteDataSource>(() =>
        _i256.ClinicsRemoteDataSource(
          iCloudService: SupabaseServices(supabase: gh<_i454.SupabaseClient>()),
        ));
    gh.lazySingleton<_i322.StaffRemoteDataSource>(() =>
        _i322.StaffRemoteDataSourceImplementation(
          iAuthServices: gh<_i662.IAuthServices>(),
          iCloudService: SupabaseServices(supabase: gh<_i454.SupabaseClient>()),
        ));
    gh.lazySingleton<_i657.ISettingsRepository>(
        () => _i955.SettingsRepositoryImpl(gh<_i239.ICloudService>()));
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
    gh.lazySingleton<_i25.IAuthRemoteDataSource>(
        () => _i25.AuthRemoteDataSourceImpl(
              SupabaseServices(supabase: gh<_i454.SupabaseClient>()),
              gh<_i662.IAuthServices>(),
            ));
    gh.factory<_i560.ExpensesCubit>(
        () => _i560.ExpensesCubit(gh<_i490.ExpensesRepository>()));
    gh.factory<_i329.PrescriptionBloc>(
        () => _i329.PrescriptionBloc(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i359.ClinicsRepository>(() =>
        _i0.ClinicsRepoImplementation(
            iClinicsRemoteDataSource: gh<_i256.IClinicsRemoteDataSource>()));
    gh.factory<_i600.ReportsCubit>(
        () => _i600.ReportsCubit(gh<_i985.ReportsRepository>()));
    gh.factory<_i709.SettingsCubit>(
        () => _i709.SettingsCubit(gh<_i657.ISettingsRepository>()));
    gh.lazySingleton<_i589.IAuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i25.IAuthRemoteDataSource>()));
    gh.factory<_i795.InvoicesCubit>(
        () => _i795.InvoicesCubit(gh<_i317.InvoicesRepository>()));
    gh.factory<_i747.AddClinicUseCase>(() => _i747.AddClinicUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i25.AddStaffUseCase>(() =>
        _i25.AddStaffUseCase(clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i2.DeleteClinicUseCase>(() => _i2.DeleteClinicUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i542.DeleteStaffUseCase>(() => _i542.DeleteStaffUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i240.EditClinicUseCase>(() => _i240.EditClinicUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i236.FetchClinicsUseCase>(() => _i236.FetchClinicsUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i665.FetchClinicByIdUseCase>(() => _i665.FetchClinicByIdUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i468.FetchClinicStaffUseCase>(() =>
        _i468.FetchClinicStaffUseCase(
            clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i143.FetchClinicStatisticsUseCase>(() =>
        _i143.FetchClinicStatisticsUseCase(
            clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i444.ToggleIsActiveUseCase>(() => _i444.ToggleIsActiveUseCase(
        clinicsRepository: gh<_i359.ClinicsRepository>()));
    gh.factory<_i750.FetchClinicStaffCubit>(
        () => _i750.FetchClinicStaffCubit(gh<_i468.FetchClinicStaffUseCase>()));
    gh.factory<_i158.SecretaryDashboardCubit>(
        () => _i158.SecretaryDashboardCubit(
              gh<_i1070.AppointmentsRepository>(),
              gh<_i239.ICloudService>(),
            ));
    gh.lazySingleton<_i841.StaffRepository>(() => _i511.StaffRepoImplementation(
        staffRemoteDataSource: gh<_i322.StaffRemoteDataSource>()));
    gh.factory<_i296.PatientsCubit>(
        () => _i296.PatientsCubit(gh<_i603.PatientsRepository>()));
    gh.factory<_i728.FetchClinicStatisticsCubit>(() =>
        _i728.FetchClinicStatisticsCubit(
            gh<_i143.FetchClinicStatisticsUseCase>()));
    gh.factory<_i169.ClinicsCubit>(() => _i169.ClinicsCubit(
          fetchClinicsUseCase: gh<_i236.FetchClinicsUseCase>(),
          addClinicUseCase: gh<_i747.AddClinicUseCase>(),
          editClinicUseCase: gh<_i240.EditClinicUseCase>(),
          deleteClinicUseCase: gh<_i2.DeleteClinicUseCase>(),
          toggleIsActiveUseCase: gh<_i444.ToggleIsActiveUseCase>(),
          addStaffUseCase: gh<_i25.AddStaffUseCase>(),
          deleteStaffUseCase: gh<_i542.DeleteStaffUseCase>(),
        ));
    gh.factory<_i730.AcceptInvitationUseCase>(
        () => _i730.AcceptInvitationUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i129.GetCurrentUserUseCase>(
        () => _i129.GetCurrentUserUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i1051.GetInvitationByTokenUseCase>(
        () => _i1051.GetInvitationByTokenUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i619.IsEmailVerifiedUseCase>(
        () => _i619.IsEmailVerifiedUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i652.LoginWithAppleUseCase>(
        () => _i652.LoginWithAppleUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i394.LoginWithEmailAndPasswordUseCase>(() =>
        _i394.LoginWithEmailAndPasswordUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i490.LoginWithGoogleUseCase>(
        () => _i490.LoginWithGoogleUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i698.LogoutUseCase>(
        () => _i698.LogoutUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i488.RegisterOwnerUseCase>(
        () => _i488.RegisterOwnerUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i695.SendMagicLinkUseCase>(
        () => _i695.SendMagicLinkUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i421.VerifyEmailUseCase>(
        () => _i421.VerifyEmailUseCase(gh<_i589.IAuthRepository>()));
    gh.factory<_i317.FetchClinicByIdCubit>(
        () => _i317.FetchClinicByIdCubit(gh<_i665.FetchClinicByIdUseCase>()));
    gh.factory<_i929.CancelInvitationUseCase>(() =>
        _i929.CancelInvitationUseCase(
            staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i801.DeleteStaffUseCase>(() =>
        _i801.DeleteStaffUseCase(staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i787.EditStaffEntityUseCase>(() => _i787.EditStaffEntityUseCase(
        staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i756.FetchAllStaffUseCase>(() => _i756.FetchAllStaffUseCase(
        staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i366.FetchPendingInvitationsUseCase>(() =>
        _i366.FetchPendingInvitationsUseCase(
            staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i445.FetchStaffByIsUseCase>(() => _i445.FetchStaffByIsUseCase(
        staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i358.InviteStaffUseCase>(() =>
        _i358.InviteStaffUseCase(staffRepository: gh<_i841.StaffRepository>()));
    gh.factory<_i888.AuthCubit>(() => _i888.AuthCubit(
          gh<_i129.GetCurrentUserUseCase>(),
          gh<_i490.LoginWithGoogleUseCase>(),
          gh<_i652.LoginWithAppleUseCase>(),
          gh<_i394.LoginWithEmailAndPasswordUseCase>(),
          gh<_i488.RegisterOwnerUseCase>(),
          gh<_i698.LogoutUseCase>(),
        ));
    gh.factory<_i165.InviteStaffCubit>(() => _i165.InviteStaffCubit(
          fetchAllStaffUseCase: gh<_i756.FetchAllStaffUseCase>(),
          inviteStaffUseCase: gh<_i358.InviteStaffUseCase>(),
        ));
    gh.factory<_i441.StaffCubit>(() => _i441.StaffCubit(
          fetchAllStaffUseCase: gh<_i756.FetchAllStaffUseCase>(),
          fetchStaffByIsUseCase: gh<_i445.FetchStaffByIsUseCase>(),
          fetchPendingInvitationsUseCase:
              gh<_i366.FetchPendingInvitationsUseCase>(),
          deleteStaffUseCase: gh<_i801.DeleteStaffUseCase>(),
          editStaffEntityUseCase: gh<_i787.EditStaffEntityUseCase>(),
          inviteStaffUseCase: gh<_i358.InviteStaffUseCase>(),
          cancelInvitationUseCase: gh<_i929.CancelInvitationUseCase>(),
        ));
    gh.factory<_i189.AcceptInvitationCubit>(() => _i189.AcceptInvitationCubit(
          gh<_i1051.GetInvitationByTokenUseCase>(),
          gh<_i730.AcceptInvitationUseCase>(),
          gh<_i490.LoginWithGoogleUseCase>(),
          gh<_i652.LoginWithAppleUseCase>(),
          gh<_i698.LogoutUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
