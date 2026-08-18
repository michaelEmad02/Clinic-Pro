// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/appointments/data/data_sources/appointment_remote_data_source_impl.dart'
    as _i590;
import '../../features/appointments/data/data_sources/i_appointment_remote_data_source.dart'
    as _i720;
import '../../features/appointments/data/repositories/appointment_repository_impl.dart'
    as _i155;
import '../../features/appointments/domain/repositories/i_appointment_repository.dart'
    as _i330;
import '../../features/appointments/domain/usecases/appointments/add_appointment_usecase.dart'
    as _i994;
import '../../features/appointments/domain/usecases/appointments/call_patient_usecase.dart'
    as _i95;
import '../../features/appointments/domain/usecases/appointments/cancel_appointment_usecase.dart'
    as _i449;
import '../../features/appointments/domain/usecases/appointments/confirm_arrival_usecase.dart'
    as _i431;
import '../../features/appointments/domain/usecases/appointments/delete_appointment_usecase.dart'
    as _i373;
import '../../features/appointments/domain/usecases/appointments/get_appointment_by_id_usecase.dart'
    as _i209;
import '../../features/appointments/domain/usecases/appointments/get_appointments_usecase.dart'
    as _i228;
import '../../features/appointments/domain/usecases/appointments/sort_queue_usecase.dart'
    as _i20;
import '../../features/appointments/domain/usecases/appointments/subscribe_appointments_usecase.dart'
    as _i486;
import '../../features/appointments/domain/usecases/appointments/toggle_urgent_usecase.dart'
    as _i367;
import '../../features/appointments/domain/usecases/appointments/update_appointment_status_usecase.dart'
    as _i996;
import '../../features/appointments/domain/usecases/appointments/update_appointment_usecase.dart'
    as _i807;
import '../../features/appointments/presentation/manager/appointments_bloc.dart'
    as _i780;
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
import '../../features/dashboard/data/datasources/i_owner_dashboard_remote_data_source.dart'
    as _i885;
import '../../features/dashboard/data/datasources/owner_dashboard_remote_data_source_impl.dart'
    as _i886;
import '../../features/dashboard/data/repositories/owner_dashboard_repository_impl.dart'
    as _i887;
import '../../features/dashboard/domain/repositories/i_owner_dashboard_repository.dart'
    as _i888;
import '../../features/dashboard/domain/usecases/get_owner_summary_stats_usecase.dart'
    as _i889;
import '../../features/dashboard/domain/usecases/get_owner_weekly_revenue_usecase.dart'
    as _i890;
import '../../features/dashboard/domain/usecases/get_owner_clinics_overview_usecase.dart'
    as _i891;
import '../../features/dashboard/domain/usecases/get_owner_alerts_usecase.dart'
    as _i892;
import '../../features/dashboard/presentation/manager/owner_summary_stats_cubit.dart'
    as _i893;
import '../../features/dashboard/presentation/manager/owner_weekly_revenue_cubit.dart'
    as _i894;
import '../../features/dashboard/presentation/manager/owner_clinics_scroll_cubit.dart'
    as _i895;
import '../../features/dashboard/presentation/manager/owner_alerts_cubit.dart'
    as _i896;
import '../../features/dashboard/presentation/manager/doctor_dashboard_cubit.dart'
    as _i683;
import '../../features/dashboard/presentation/manager/secretary_dashboard_cubit.dart'
    as _i158;
import '../../features/expenses/data/data_sources/expenses_remote_data_source.dart'
    as _i219;
import '../../features/expenses/data/repositories/expenses_repo_implementation.dart'
    as _i936;
import '../../features/expenses/domain/repositories/expenses_repository.dart'
    as _i321;
import '../../features/expenses/domain/use_cases/add_expenses_use_case.dart'
    as _i824;
import '../../features/expenses/domain/use_cases/delete_expenses_use_case.dart'
    as _i1067;
import '../../features/expenses/domain/use_cases/edit_expenses_use_case.dart'
    as _i789;
import '../../features/expenses/domain/use_cases/fetch_expenses_use_case.dart'
    as _i536;
import '../../features/expenses/presentation/manager/expenses_cubit.dart'
    as _i560;
import '../../features/expenses/presentation/manager/expenses_repository.dart'
    as _i490;
import '../../features/invoices/data/data_sources/invoices_remote_data_source.dart'
    as _i446;
import '../../features/invoices/data/repositories/invoices_repository_impl.dart'
    as _i1008;
import '../../features/invoices/domain/repositories/i_invoices_repository.dart'
    as _i247;
import '../../features/invoices/domain/usecases/create_invoice_usecase.dart'
    as _i920;
import '../../features/invoices/domain/usecases/delete_invoice_usecase.dart'
    as _i109;
import '../../features/invoices/domain/usecases/get_invoices_usecase.dart'
    as _i366;
import '../../features/invoices/domain/usecases/get_patient_unpaid_appointments_usecase.dart'
    as _i289;
import '../../features/invoices/domain/usecases/update_invoice_usecase.dart'
    as _i1072;
import '../../features/invoices/presentation/manager/invoices_cubit.dart'
    as _i795;
import '../../features/onboarding/presentation/manager/onboarding_cubit.dart'
    as _i1012;
import '../../features/patients/data/datasources/i_patients_remote_data_source.dart'
    as _i816;
import '../../features/patients/data/datasources/patients_remote_data_source_impl.dart'
    as _i472;
import '../../features/patients/data/repositories/patients_repository_impl.dart'
    as _i347;
import '../../features/patients/domain/repositories/i_patients_repository.dart'
    as _i69;
import '../../features/patients/domain/usecases/add_patient_usecase.dart'
    as _i392;
import '../../features/patients/domain/usecases/delete_patient_usecase.dart'
    as _i774;
import '../../features/patients/domain/usecases/find_patient_by_id_usecase.dart'
    as _i338;
import '../../features/patients/domain/usecases/get_prescriptions_for_patient_usecase.dart'
    as _i1061;
import '../../features/patients/domain/usecases/get_visits_for_patient_usecase.dart'
    as _i507;
import '../../features/patients/domain/usecases/load_patients_usecase.dart'
    as _i986;
import '../../features/patients/domain/usecases/update_patient_usecase.dart'
    as _i256;
import '../../features/patients/presentation/manager/patient_details_cubit.dart'
    as _i116;
import '../../features/patients/presentation/manager/patient_prescriptions_cubit.dart'
    as _i864;
import '../../features/patients/presentation/manager/patients_cubit.dart'
    as _i296;
import '../../features/plans_and_subscriptions/data/data_sources/subscriptions_remote_data_source.dart'
    as _i347;
import '../../features/plans_and_subscriptions/data/repositories/subscriptions_repository_impl.dart'
    as _i399;
import '../../features/plans_and_subscriptions/domain/repositories/i_subscriptions_repository.dart'
    as _i255;
import '../../features/plans_and_subscriptions/domain/usecases/subscriptions_usecases.dart'
    as _i944;
import '../../features/plans_and_subscriptions/presentation/manager/subscriptions_cubit.dart'
    as _i701;
import '../../features/prescription/data/datasources/prescription_remote_data_source.dart'
    as _i482;
import '../../features/prescription/data/repositories/prescription_repository_impl.dart'
    as _i678;
import '../../features/prescription/domain/repositories/i_prescription_repository.dart'
    as _i845;
import '../../features/prescription/domain/usecases/copy_previous_prescription_usecase.dart'
    as _i274;
import '../../features/prescription/domain/usecases/drugs_usecases.dart'
    as _i628;
import '../../features/prescription/domain/usecases/generate_prescription_pdf_usecase.dart'
    as _i880;
import '../../features/prescription/domain/usecases/increment_template_usage_usecase.dart'
    as _i372;
import '../../features/prescription/domain/usecases/load_prescription_data_usecase.dart'
    as _i85;
import '../../features/prescription/domain/usecases/save_prescription_usecase.dart'
    as _i712;
import '../../features/prescription/domain/usecases/templates_usecases.dart'
    as _i535;
import '../../features/prescription/presentation/manager/drugs_cubit.dart'
    as _i1042;
import '../../features/prescription/presentation/manager/prescription_bloc.dart'
    as _i329;
import '../../features/prescription/presentation/manager/prescription_pdf_cubit.dart'
    as _i51;
import '../../features/prescription/presentation/manager/templates_cubit.dart'
    as _i534;
import '../../features/reports/data/datasources/i_reports_remote_data_source.dart'
    as _i107;
import '../../features/reports/data/datasources/reports_cache_manager.dart'
    as _i777;
import '../../features/reports/data/datasources/reports_rpc_remote_data_source_impl.dart'
    as _i478;
import '../../features/reports/data/repositories/reports_repository_impl.dart'
    as _i227;
import '../../features/reports/domain/repositories/i_reports_repository.dart'
    as _i187;
import '../../features/reports/domain/usecases/get_appointment_stats_usecase.dart'
    as _i660;
import '../../features/reports/domain/usecases/get_clinic_report_usecase.dart'
    as _i1007;
import '../../features/reports/domain/usecases/get_doctor_performance_usecase.dart'
    as _i397;
import '../../features/reports/domain/usecases/get_drug_stats_usecase.dart'
    as _i965;
import '../../features/reports/domain/usecases/get_patient_stats_usecase.dart'
    as _i206;
import '../../features/reports/domain/usecases/get_revenue_summary_usecase.dart'
    as _i249;
import '../../features/reports/domain/usecases/get_template_stats_usecase.dart'
    as _i61;
import '../../features/reports/presentation/manager/appointment_reports_cubit.dart'
    as _i476;
import '../../features/reports/presentation/manager/clinic_reports_cubit.dart'
    as _i753;
import '../../features/reports/presentation/manager/doctor_my_reports_cubit.dart'
    as _i0;
import '../../features/reports/presentation/manager/doctor_performance_cubit.dart'
    as _i174;
import '../../features/reports/presentation/manager/drug_reports_cubit.dart'
    as _i405;
import '../../features/reports/presentation/manager/financial_reports_cubit.dart'
    as _i977;
import '../../features/reports/presentation/manager/patient_reports_cubit.dart'
    as _i685;
import '../../features/settings/data/data_sources/i_settings_local_data_source.dart'
    as _i769;
import '../../features/settings/data/data_sources/owner_settings_remote_data_source.dart'
    as _i1070;
import '../../features/settings/data/data_sources/settings_local_data_source_impl.dart'
    as _i917;
import '../../features/settings/data/data_sources/settings_remote_data_source.dart'
    as _i524;
import '../../features/settings/data/repositories/owner_settings_repository_impl.dart'
    as _i375;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/i_owner_settings_repository.dart'
    as _i591;
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/domain/usecases/get_available_clinics_usecase.dart'
    as _i88;
import '../../features/settings/domain/usecases/get_clinic_info_usecase.dart'
    as _i1034;
import '../../features/settings/domain/usecases/get_doctor_appointment_types_usecase.dart'
    as _i620;
import '../../features/settings/domain/usecases/get_doctor_schedules_usecase.dart'
    as _i410;
import '../../features/settings/domain/usecases/get_global_appointment_types_usecase.dart'
    as _i431;
import '../../features/settings/domain/usecases/get_owner_printing_settings_usecase.dart'
    as _i456;
import '../../features/settings/domain/usecases/get_queue_rule_usecase.dart'
    as _i924;
import '../../features/settings/domain/usecases/get_secretary_doctors_usecase.dart'
    as _i994;
import '../../features/settings/domain/usecases/get_subscription_usecase.dart'
    as _i170;
import '../../features/settings/domain/usecases/save_owner_printing_settings_usecase.dart'
    as _i602;
import '../../features/settings/domain/usecases/set_active_doctor_usecase.dart'
    as _i32;
import '../../features/settings/domain/usecases/sync_doctor_appointment_types_usecase.dart'
    as _i849;
import '../../features/settings/domain/usecases/update_clinic_info_usecase.dart'
    as _i728;
import '../../features/settings/domain/usecases/update_profile_usecase.dart'
    as _i455;
import '../../features/settings/domain/usecases/upload_avatar_usecase.dart'
    as _i190;
import '../../features/settings/domain/usecases/upsert_doctor_appointment_type_usecase.dart'
    as _i1072;
import '../../features/settings/domain/usecases/upsert_doctor_schedule_usecase.dart'
    as _i82;
import '../../features/settings/domain/usecases/upsert_queue_rule_usecase.dart'
    as _i31;
import '../../features/settings/presentation/manager/printing_settings_cubit.dart'
    as _i641;
import '../../features/settings/presentation/manager/queue_pattern_cubit.dart'
    as _i467;
import '../../features/settings/presentation/manager/settings_cubit.dart'
    as _i709;
import '../../features/staff_and_invitations/data/data_sources/staff_remote_data_source.dart'
    as _i951;
import '../../features/staff_and_invitations/data/repositories/staff_repo_implementation.dart'
    as _i418;
import '../../features/staff_and_invitations/domain/repositories/staff_repository.dart'
    as _i431;
import '../../features/staff_and_invitations/domain/use_cases/cancel_invitation_use_case.dart'
    as _i1073;
import '../../features/staff_and_invitations/domain/use_cases/delete_staff_use_case.dart'
    as _i382;
import '../../features/staff_and_invitations/domain/use_cases/edit_staff_entity_use_case.dart'
    as _i973;
import '../../features/staff_and_invitations/domain/use_cases/fetch_all_staff_use_case.dart'
    as _i675;
import '../../features/staff_and_invitations/domain/use_cases/fetch_pending_invitations_use_case.dart'
    as _i273;
import '../../features/staff_and_invitations/domain/use_cases/fetch_staff_by_is_use_case.dart'
    as _i36;
import '../../features/staff_and_invitations/domain/use_cases/invite_staff_use_case.dart'
    as _i255;
import '../../features/staff_and_invitations/presentation/manager/invite_staff_cubit.dart'
    as _i628;
import '../../features/staff_and_invitations/presentation/manager/staff_cubit.dart'
    as _i815;
import '../localization/language_cubit.dart' as _i170;
import '../services/i_auth_services.dart' as _i662;
import '../services/i_cloud_service.dart' as _i239;
import '../services/i_local_data_service.dart' as _i819;
import '../services/i_prescription_pdf_service.dart' as _i581;
import '../services/prescription_pdf_service_impl.dart' as _i926;
import '../services/shared_preferences_service.dart' as _i29;
import '../services/storage/i_image_compression_service.dart' as _i576;
import '../services/storage/i_storage_service.dart' as _i557;
import '../services/storage/image_compression_service.dart' as _i26;
import '../services/storage/supabase_storage_service.dart' as _i815;
import '../services/supabase_auth_services.dart' as _i693;
import '../services/supabase_services.dart' as _i1019;
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
    gh.factory<_i20.SortQueueUseCase>(() => _i20.SortQueueUseCase());
    gh.factory<_i1012.OnboardingCubit>(() => _i1012.OnboardingCubit());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabase);
    gh.lazySingleton<_i777.ReportsCacheManager>(
        () => _i777.ReportsCacheManager());
    gh.lazySingleton<_i170.LanguageCubit>(
        () => _i170.LanguageCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i965.ThemeCubit>(
        () => _i965.ThemeCubit(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i576.IImageCompressionService>(
        () => _i26.ImageCompressionService());
    gh.lazySingleton<_i581.IPrescriptionPdfService>(
        () => _i926.PrescriptionPdfServiceImpl());
    gh.lazySingleton<_i321.ExpensesRepository>(
        () => _i936.ExpensesRepoImplementation());
    gh.lazySingleton<_i819.ILocalDataService>(
        () => _i29.SharedPreferencesService(gh<_i460.SharedPreferences>()));
    gh.lazySingleton<_i662.IAuthServices>(
        () => _i693.SupabaseAuthServices(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i239.ICloudService>(
        () => _i1019.SupabaseServices(supabase: gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i720.IAppointmentRemoteDataSource>(
        () => _i590.AppointmentRemoteDataSourceImpl(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i816.IPatientsRemoteDataSource>(
        () => _i472.PatientsRemoteDataSourceImpl(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i951.StaffRemoteDataSource>(
        () => _i951.StaffRemoteDataSourceImplementation(
              iAuthServices: gh<_i662.IAuthServices>(),
              iCloudService: gh<_i239.ICloudService>(),
            ));
    gh.lazySingleton<_i347.ISubscriptionsRemoteDataSource>(
        () => _i347.SubscriptionsRemoteDataSource(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i255.ISubscriptionsRepository>(() =>
        _i399.SubscriptionsRepositoryImpl(
            gh<_i347.ISubscriptionsRemoteDataSource>()));
    gh.lazySingleton<_i885.IOwnerDashboardRemoteDataSource>(
        () => _i886.OwnerDashboardRemoteDataSourceImpl(
              gh<_i239.ICloudService>(),
            ));
    gh.lazySingleton<_i888.IOwnerDashboardRepository>(
        () => _i887.OwnerDashboardRepositoryImpl(
              gh<_i885.IOwnerDashboardRemoteDataSource>(),
            ));
    gh.lazySingleton<_i889.GetOwnerSummaryStatsUseCase>(
        () => _i889.GetOwnerSummaryStatsUseCase(
              gh<_i888.IOwnerDashboardRepository>(),
            ));
    gh.lazySingleton<_i890.GetOwnerWeeklyRevenueUseCase>(
        () => _i890.GetOwnerWeeklyRevenueUseCase(
              gh<_i888.IOwnerDashboardRepository>(),
            ));
    gh.lazySingleton<_i891.GetOwnerClinicsOverviewUseCase>(
        () => _i891.GetOwnerClinicsOverviewUseCase(
              gh<_i888.IOwnerDashboardRepository>(),
            ));
    gh.lazySingleton<_i892.GetOwnerAlertsUseCase>(
        () => _i892.GetOwnerAlertsUseCase(
              gh<_i888.IOwnerDashboardRepository>(),
            ));
    gh.factory<_i893.OwnerSummaryStatsCubit>(
        () => _i893.OwnerSummaryStatsCubit(gh<_i889.GetOwnerSummaryStatsUseCase>()));
    gh.factory<_i894.OwnerWeeklyRevenueCubit>(
        () => _i894.OwnerWeeklyRevenueCubit(gh<_i890.GetOwnerWeeklyRevenueUseCase>()));
    gh.factory<_i895.OwnerClinicsScrollCubit>(
        () => _i895.OwnerClinicsScrollCubit(gh<_i891.GetOwnerClinicsOverviewUseCase>()));
    gh.factory<_i896.OwnerAlertsCubit>(
        () => _i896.OwnerAlertsCubit(gh<_i892.GetOwnerAlertsUseCase>()));
    gh.factory<_i490.ExpensesRepository>(
        () => _i490.ExpensesRepository(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i557.IStorageService>(
        () => _i815.SupabaseStorageService(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i446.IInvoicesRemoteDataSource>(
        () => _i446.InvoicesRemoteDataSourceImpl(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i25.IAuthRemoteDataSource>(
        () => _i25.AuthRemoteDataSourceImpl(
              gh<_i239.ICloudService>(),
              gh<_i662.IAuthServices>(),
            ));
    gh.factory<_i560.ExpensesCubit>(
        () => _i560.ExpensesCubit(gh<_i490.ExpensesRepository>()));
    gh.factory<_i824.AddExpensesUseCase>(() => _i824.AddExpensesUseCase(
        expensesRepository: gh<_i321.ExpensesRepository>()));
    gh.factory<_i1067.DeleteExpensesUseCase>(() => _i1067.DeleteExpensesUseCase(
        expensesRepository: gh<_i321.ExpensesRepository>()));
    gh.factory<_i789.EditExpensesUseCase>(() => _i789.EditExpensesUseCase(
        expensesRepository: gh<_i321.ExpensesRepository>()));
    gh.factory<_i536.FetchExpensesUseCase>(() => _i536.FetchExpensesUseCase(
        expensesRepository: gh<_i321.ExpensesRepository>()));
    gh.lazySingleton<_i769.ISettingsLocalDataSource>(
        () => _i917.SettingsLocalDataSourceImpl(gh<_i819.ILocalDataService>()));
    gh.lazySingleton<_i431.StaffRepository>(() => _i418.StaffRepoImplementation(
        staffRemoteDataSource: gh<_i951.StaffRemoteDataSource>()));
    gh.lazySingleton<_i589.IAuthRepository>(
        () => _i153.AuthRepositoryImpl(gh<_i25.IAuthRemoteDataSource>()));
    gh.lazySingleton<_i219.IClinicsRemoteDataSource>(() =>
        _i219.ClinicsRemoteDataSource(
            iCloudService: gh<_i239.ICloudService>()));
    gh.lazySingleton<_i256.IClinicsRemoteDataSource>(() =>
        _i256.ClinicsRemoteDataSource(
            iCloudService: gh<_i239.ICloudService>()));
    gh.lazySingleton<_i247.IInvoicesRepository>(() =>
        _i1008.InvoicesRepositoryImpl(gh<_i446.IInvoicesRemoteDataSource>()));
    gh.lazySingleton<_i482.IPrescriptionRemoteDataSource>(
        () => _i482.PrescriptionRemoteDataSourceImpl(
              gh<_i239.ICloudService>(),
              gh<_i581.IPrescriptionPdfService>(),
            ));
    gh.lazySingleton<_i1070.IOwnerSettingsRemoteDataSource>(() =>
        _i1070.OwnerSettingsRemoteDataSourceImpl(gh<_i239.ICloudService>()));
    gh.lazySingleton<_i107.IReportsRemoteDataSource>(
        () => _i478.ReportsRpcRemoteDataSourceImpl(gh<_i239.ICloudService>(),gh<_i777.ReportsCacheManager>()));
    gh.lazySingleton<_i330.IAppointmentRepository>(() =>
        _i155.AppointmentRepositoryImpl(
            gh<_i720.IAppointmentRemoteDataSource>()));
    gh.lazySingleton<_i69.IPatientsRepository>(() =>
        _i347.PatientsRepositoryImpl(gh<_i816.IPatientsRemoteDataSource>()));
    gh.lazySingleton<_i591.IOwnerSettingsRepository>(() =>
        _i375.OwnerSettingsRepositoryImpl(
            gh<_i1070.IOwnerSettingsRemoteDataSource>()));
    gh.lazySingleton<_i944.GetPlansUseCase>(
        () => _i944.GetPlansUseCase(gh<_i255.ISubscriptionsRepository>()));
    gh.lazySingleton<_i944.GetActiveSubscriptionUseCase>(() =>
        _i944.GetActiveSubscriptionUseCase(
            gh<_i255.ISubscriptionsRepository>()));
    gh.lazySingleton<_i944.CheckSubscriptionStatusUseCase>(() =>
        _i944.CheckSubscriptionStatusUseCase(
            gh<_i255.ISubscriptionsRepository>()));
    gh.lazySingleton<_i944.RequestSubscriptionUseCase>(() =>
        _i944.RequestSubscriptionUseCase(gh<_i255.ISubscriptionsRepository>()));
    gh.lazySingleton<_i944.GetCompanyInfoUseCase>(() =>
        _i944.GetCompanyInfoUseCase(gh<_i255.ISubscriptionsRepository>()));
    gh.lazySingleton<_i944.GetSubscriptionUsageUseCase>(() =>
        _i944.GetSubscriptionUsageUseCase(
            gh<_i255.ISubscriptionsRepository>()));
    gh.factory<_i701.SubscriptionsCubit>(() => _i701.SubscriptionsCubit(
          getPlansUseCase: gh<_i944.GetPlansUseCase>(),
          checkSubscriptionStatusUseCase:
              gh<_i944.CheckSubscriptionStatusUseCase>(),
          requestSubscriptionUseCase: gh<_i944.RequestSubscriptionUseCase>(),
          getCompanyInfoUseCase: gh<_i944.GetCompanyInfoUseCase>(),
          getSubscriptionUsageUseCase: gh<_i944.GetSubscriptionUsageUseCase>(),
        ));
    gh.factory<_i1073.CancelInvitationUseCase>(() =>
        _i1073.CancelInvitationUseCase(
            staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i382.DeleteStaffUseCase>(() =>
        _i382.DeleteStaffUseCase(staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i973.EditStaffEntityUseCase>(() => _i973.EditStaffEntityUseCase(
        staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i675.FetchAllStaffUseCase>(() => _i675.FetchAllStaffUseCase(
        staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i273.FetchPendingInvitationsUseCase>(() =>
        _i273.FetchPendingInvitationsUseCase(
            staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i36.FetchStaffByIsUseCase>(() => _i36.FetchStaffByIsUseCase(
        staffRepository: gh<_i431.StaffRepository>()));
    gh.factory<_i255.InviteStaffUseCase>(() => _i255.InviteStaffUseCase(
          staffRepository: gh<_i431.StaffRepository>(),
          subscriptionsRepository: gh<_i255.ISubscriptionsRepository>(),
        ));
    gh.factory<_i920.CreateInvoiceUseCase>(
        () => _i920.CreateInvoiceUseCase(gh<_i247.IInvoicesRepository>()));
    gh.factory<_i109.DeleteInvoiceUseCase>(
        () => _i109.DeleteInvoiceUseCase(gh<_i247.IInvoicesRepository>()));
    gh.factory<_i366.GetInvoicesUseCase>(
        () => _i366.GetInvoicesUseCase(gh<_i247.IInvoicesRepository>()));
    gh.factory<_i289.GetPatientUnpaidAppointmentsUseCase>(() =>
        _i289.GetPatientUnpaidAppointmentsUseCase(
            gh<_i247.IInvoicesRepository>()));
    gh.factory<_i1072.UpdateInvoiceUseCase>(
        () => _i1072.UpdateInvoiceUseCase(gh<_i247.IInvoicesRepository>()));
    gh.lazySingleton<_i486.SubscribeAppointmentsUseCase>(() =>
        _i486.SubscribeAppointmentsUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i994.AddAppointmentUseCase>(
        () => _i994.AddAppointmentUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i95.CallPatientUseCase>(
        () => _i95.CallPatientUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i449.CancelAppointmentUseCase>(() =>
        _i449.CancelAppointmentUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i431.ConfirmArrivalUseCase>(
        () => _i431.ConfirmArrivalUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i373.DeleteAppointmentUseCase>(() =>
        _i373.DeleteAppointmentUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i228.GetAppointmentsUseCase>(
        () => _i228.GetAppointmentsUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i209.GetAppointmentByIdUseCase>(() =>
        _i209.GetAppointmentByIdUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i367.ToggleUrgentUseCase>(
        () => _i367.ToggleUrgentUseCase(gh<_i330.IAppointmentRepository>()));
    gh.factory<_i996.UpdateAppointmentStatusUseCase>(() =>
        _i996.UpdateAppointmentStatusUseCase(
            gh<_i330.IAppointmentRepository>()));
    gh.factory<_i807.UpdateAppointmentUseCase>(() =>
        _i807.UpdateAppointmentUseCase(gh<_i330.IAppointmentRepository>()));
    gh.lazySingleton<_i524.ISettingsRemoteDataSource>(
        () => _i524.SettingsRemoteDataSource(
              gh<_i239.ICloudService>(),
              gh<_i557.IStorageService>(),
              gh<_i576.IImageCompressionService>(),
            ));
    gh.factory<_i158.SecretaryDashboardCubit>(
        () => _i158.SecretaryDashboardCubit(
              gh<_i228.GetAppointmentsUseCase>(),
              gh<_i431.ConfirmArrivalUseCase>(),
              gh<_i95.CallPatientUseCase>(),
              gh<_i239.ICloudService>(),
            ));
    gh.factory<_i392.AddPatientUseCase>(() => _i392.AddPatientUseCase(
          gh<_i69.IPatientsRepository>(),
          gh<_i255.ISubscriptionsRepository>(),
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
    gh.lazySingleton<_i359.ClinicsRepository>(() =>
        _i0.ClinicsRepoImplementation(
            iClinicsRemoteDataSource: gh<_i256.IClinicsRemoteDataSource>()));
    gh.lazySingleton<_i845.IPrescriptionRepository>(() =>
        _i678.PrescriptionRepositoryImpl(
            gh<_i482.IPrescriptionRemoteDataSource>()));
    gh.lazySingleton<_i657.ISettingsRepository>(() =>
        _i955.SettingsRepositoryImpl(gh<_i524.ISettingsRemoteDataSource>()));
    gh.factory<_i683.DoctorDashboardCubit>(() => _i683.DoctorDashboardCubit(
          gh<_i228.GetAppointmentsUseCase>(),
          gh<_i95.CallPatientUseCase>(),
          gh<_i20.SortQueueUseCase>(),
          gh<_i239.ICloudService>(),
        ));
    gh.lazySingleton<_i456.GetOwnerPrintingSettingsUseCase>(() =>
        _i456.GetOwnerPrintingSettingsUseCase(
            gh<_i591.IOwnerSettingsRepository>()));
    gh.lazySingleton<_i602.SaveOwnerPrintingSettingsUseCase>(() =>
        _i602.SaveOwnerPrintingSettingsUseCase(
            gh<_i591.IOwnerSettingsRepository>()));
    gh.factory<_i88.GetAvailableClinicsUseCase>(
        () => _i88.GetAvailableClinicsUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i1034.GetClinicInfoUseCase>(
        () => _i1034.GetClinicInfoUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i620.GetDoctorAppointmentTypesUseCase>(() =>
        _i620.GetDoctorAppointmentTypesUseCase(
            gh<_i657.ISettingsRepository>()));
    gh.factory<_i410.GetDoctorSchedulesUseCase>(
        () => _i410.GetDoctorSchedulesUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i431.GetGlobalAppointmentTypesUseCase>(() =>
        _i431.GetGlobalAppointmentTypesUseCase(
            gh<_i657.ISettingsRepository>()));
    gh.factory<_i924.GetQueueRuleUseCase>(
        () => _i924.GetQueueRuleUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i994.GetSecretaryDoctorsUseCase>(() =>
        _i994.GetSecretaryDoctorsUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i170.GetSubscriptionUseCase>(
        () => _i170.GetSubscriptionUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i32.SetActiveDoctorUseCase>(
        () => _i32.SetActiveDoctorUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i849.SyncDoctorAppointmentTypesUseCase>(() =>
        _i849.SyncDoctorAppointmentTypesUseCase(
            gh<_i657.ISettingsRepository>()));
    gh.factory<_i728.UpdateClinicInfoUseCase>(
        () => _i728.UpdateClinicInfoUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i455.UpdateProfileUseCase>(
        () => _i455.UpdateProfileUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i190.UploadAvatarUseCase>(
        () => _i190.UploadAvatarUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i1072.UpsertDoctorAppointmentTypeUseCase>(() =>
        _i1072.UpsertDoctorAppointmentTypeUseCase(
            gh<_i657.ISettingsRepository>()));
    gh.factory<_i82.UpsertDoctorScheduleUseCase>(() =>
        _i82.UpsertDoctorScheduleUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i31.UpsertQueueRuleUseCase>(
        () => _i31.UpsertQueueRuleUseCase(gh<_i657.ISettingsRepository>()));
    gh.factory<_i274.CopyPreviousPrescriptionUseCase>(() =>
        _i274.CopyPreviousPrescriptionUseCase(
            gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i628.GetDrugsUseCase>(
        () => _i628.GetDrugsUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i628.AddDrugUseCase>(
        () => _i628.AddDrugUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i628.UpdateDrugUseCase>(
        () => _i628.UpdateDrugUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i628.DeleteDrugUseCase>(
        () => _i628.DeleteDrugUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i85.LoadPrescriptionDataUseCase>(() =>
        _i85.LoadPrescriptionDataUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i712.SavePrescriptionUseCase>(() =>
        _i712.SavePrescriptionUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i535.GetTemplatesUseCase>(
        () => _i535.GetTemplatesUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i535.AddTemplateUseCase>(
        () => _i535.AddTemplateUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i535.EditTemplateUseCase>(
        () => _i535.EditTemplateUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i535.DeleteTemplateUseCase>(
        () => _i535.DeleteTemplateUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i535.GetTemplateDataUseCase>(() =>
        _i535.GetTemplateDataUseCase(gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i880.GeneratePrescriptionPdfUseCase>(() =>
        _i880.GeneratePrescriptionPdfUseCase(
            gh<_i845.IPrescriptionRepository>()));
    gh.factory<_i372.IncrementTemplateUsageUseCase>(() =>
        _i372.IncrementTemplateUsageUseCase(
            gh<_i845.IPrescriptionRepository>()));
    gh.lazySingleton<_i187.IReportsRepository>(() =>
        _i227.ReportsRepositoryImpl(gh<_i107.IReportsRemoteDataSource>()));
    gh.factory<_i774.DeletePatientUseCase>(
        () => _i774.DeletePatientUseCase(gh<_i69.IPatientsRepository>()));
    gh.factory<_i338.FindPatientByIdUseCase>(
        () => _i338.FindPatientByIdUseCase(gh<_i69.IPatientsRepository>()));
    gh.factory<_i1061.GetPrescriptionsForPatientUseCase>(() =>
        _i1061.GetPrescriptionsForPatientUseCase(
            gh<_i69.IPatientsRepository>()));
    gh.factory<_i507.GetVisitsForPatientUseCase>(
        () => _i507.GetVisitsForPatientUseCase(gh<_i69.IPatientsRepository>()));
    gh.factory<_i986.LoadPatientsUseCase>(
        () => _i986.LoadPatientsUseCase(gh<_i69.IPatientsRepository>()));
    gh.factory<_i256.UpdatePatientUseCase>(
        () => _i256.UpdatePatientUseCase(gh<_i69.IPatientsRepository>()));
    gh.factory<_i329.PrescriptionBloc>(() => _i329.PrescriptionBloc(
          gh<_i85.LoadPrescriptionDataUseCase>(),
          gh<_i712.SavePrescriptionUseCase>(),
          gh<_i274.CopyPreviousPrescriptionUseCase>(),
          gh<_i535.GetTemplateDataUseCase>(),
          gh<_i372.IncrementTemplateUsageUseCase>(),
        ));
    gh.factory<_i780.AppointmentsBloc>(() => _i780.AppointmentsBloc(
          gh<_i228.GetAppointmentsUseCase>(),
          gh<_i431.ConfirmArrivalUseCase>(),
          gh<_i449.CancelAppointmentUseCase>(),
          gh<_i367.ToggleUrgentUseCase>(),
          gh<_i994.AddAppointmentUseCase>(),
          gh<_i807.UpdateAppointmentUseCase>(),
          gh<_i373.DeleteAppointmentUseCase>(),
          gh<_i209.GetAppointmentByIdUseCase>(),
          gh<_i486.SubscribeAppointmentsUseCase>(),
        ));
    gh.factory<_i1042.DrugsCubit>(() => _i1042.DrugsCubit(
          gh<_i628.GetDrugsUseCase>(),
          gh<_i628.AddDrugUseCase>(),
          gh<_i628.UpdateDrugUseCase>(),
          gh<_i628.DeleteDrugUseCase>(),
        ));
    gh.factory<_i628.InviteStaffCubit>(() => _i628.InviteStaffCubit(
          fetchAllStaffUseCase: gh<_i675.FetchAllStaffUseCase>(),
          inviteStaffUseCase: gh<_i255.InviteStaffUseCase>(),
        ));
    gh.factory<_i2.DeleteClinicUseCase>(() => _i2.DeleteClinicUseCase(
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
    gh.factory<_i467.QueuePatternCubit>(() => _i467.QueuePatternCubit(
          gh<_i924.GetQueueRuleUseCase>(),
          gh<_i31.UpsertQueueRuleUseCase>(),
          gh<_i620.GetDoctorAppointmentTypesUseCase>(),
          gh<_i431.GetGlobalAppointmentTypesUseCase>(),
        ));
    gh.factory<_i864.PatientPrescriptionsCubit>(() =>
        _i864.PatientPrescriptionsCubit(
            gh<_i1061.GetPrescriptionsForPatientUseCase>()));
    gh.factory<_i709.SettingsCubit>(() => _i709.SettingsCubit(
          gh<_i455.UpdateProfileUseCase>(),
          gh<_i1034.GetClinicInfoUseCase>(),
          gh<_i88.GetAvailableClinicsUseCase>(),
          gh<_i170.GetSubscriptionUseCase>(),
          gh<_i994.GetSecretaryDoctorsUseCase>(),
          gh<_i32.SetActiveDoctorUseCase>(),
          gh<_i190.UploadAvatarUseCase>(),
          gh<_i675.FetchAllStaffUseCase>(),
          gh<_i769.ISettingsLocalDataSource>(),
        ));
    gh.factory<_i815.StaffCubit>(() => _i815.StaffCubit(
          fetchAllStaffUseCase: gh<_i675.FetchAllStaffUseCase>(),
          fetchStaffByIsUseCase: gh<_i36.FetchStaffByIsUseCase>(),
          fetchPendingInvitationsUseCase:
              gh<_i273.FetchPendingInvitationsUseCase>(),
          deleteStaffUseCase: gh<_i382.DeleteStaffUseCase>(),
          editStaffEntityUseCase: gh<_i973.EditStaffEntityUseCase>(),
          inviteStaffUseCase: gh<_i255.InviteStaffUseCase>(),
          cancelInvitationUseCase: gh<_i1073.CancelInvitationUseCase>(),
        ));
    gh.factory<_i750.FetchClinicStaffCubit>(
        () => _i750.FetchClinicStaffCubit(gh<_i468.FetchClinicStaffUseCase>()));
    gh.factory<_i296.PatientsCubit>(() => _i296.PatientsCubit(
          gh<_i986.LoadPatientsUseCase>(),
          gh<_i392.AddPatientUseCase>(),
          gh<_i256.UpdatePatientUseCase>(),
          gh<_i774.DeletePatientUseCase>(),
        ));
    gh.factory<_i534.TemplatesCubit>(() => _i534.TemplatesCubit(
          gh<_i535.GetTemplatesUseCase>(),
          gh<_i535.AddTemplateUseCase>(),
          gh<_i535.EditTemplateUseCase>(),
          gh<_i535.DeleteTemplateUseCase>(),
        ));
    gh.factory<_i888.AuthCubit>(() => _i888.AuthCubit(
          gh<_i129.GetCurrentUserUseCase>(),
          gh<_i490.LoginWithGoogleUseCase>(),
          gh<_i652.LoginWithAppleUseCase>(),
          gh<_i394.LoginWithEmailAndPasswordUseCase>(),
          gh<_i488.RegisterOwnerUseCase>(),
          gh<_i698.LogoutUseCase>(),
          gh<_i944.CheckSubscriptionStatusUseCase>(),
        ));
    gh.factory<_i747.AddClinicUseCase>(() => _i747.AddClinicUseCase(
          clinicsRepository: gh<_i359.ClinicsRepository>(),
          subscriptionsRepository: gh<_i255.ISubscriptionsRepository>(),
        ));
    gh.factory<_i25.AddStaffUseCase>(() => _i25.AddStaffUseCase(
          clinicsRepository: gh<_i359.ClinicsRepository>(),
          subscriptionsRepository: gh<_i255.ISubscriptionsRepository>(),
        ));
    gh.factory<_i660.GetAppointmentStatsUseCase>(
        () => _i660.GetAppointmentStatsUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i397.GetDoctorPerformanceUseCase>(() =>
        _i397.GetDoctorPerformanceUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i965.GetDrugStatsUseCase>(
        () => _i965.GetDrugStatsUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i206.GetPatientStatsUseCase>(
        () => _i206.GetPatientStatsUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i249.GetRevenueSummaryUseCase>(
        () => _i249.GetRevenueSummaryUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i61.GetTemplateStatsUseCase>(
        () => _i61.GetTemplateStatsUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i1007.GetClinicReportUseCase>(
        () => _i1007.GetClinicReportUseCase(gh<_i187.IReportsRepository>()));
    gh.factory<_i562.WaitingQueueCubit>(() => _i562.WaitingQueueCubit(
          gh<_i228.GetAppointmentsUseCase>(),
          gh<_i95.CallPatientUseCase>(),
          gh<_i924.GetQueueRuleUseCase>(),
          gh<_i20.SortQueueUseCase>(),
          gh<_i486.SubscribeAppointmentsUseCase>(),
        ));
    gh.factory<_i0.DoctorMyReportsCubit>(() => _i0.DoctorMyReportsCubit(
          gh<_i249.GetRevenueSummaryUseCase>(),
          gh<_i660.GetAppointmentStatsUseCase>(),
          gh<_i206.GetPatientStatsUseCase>(),
          gh<_i965.GetDrugStatsUseCase>(),
          gh<_i61.GetTemplateStatsUseCase>(),
        ));
    gh.factory<_i51.PrescriptionPdfCubit>(() => _i51.PrescriptionPdfCubit(
          gh<_i880.GeneratePrescriptionPdfUseCase>(),
          gh<_i456.GetOwnerPrintingSettingsUseCase>(),
        ));
    gh.factory<_i728.FetchClinicStatisticsCubit>(() =>
        _i728.FetchClinicStatisticsCubit(
            gh<_i143.FetchClinicStatisticsUseCase>()));
    gh.factory<_i189.AcceptInvitationCubit>(() => _i189.AcceptInvitationCubit(
          gh<_i1051.GetInvitationByTokenUseCase>(),
          gh<_i730.AcceptInvitationUseCase>(),
          gh<_i490.LoginWithGoogleUseCase>(),
          gh<_i652.LoginWithAppleUseCase>(),
          gh<_i698.LogoutUseCase>(),
        ));
    gh.factory<_i685.PatientReportsCubit>(
        () => _i685.PatientReportsCubit(gh<_i206.GetPatientStatsUseCase>()));
    gh.factory<_i641.PrintingSettingsCubit>(() => _i641.PrintingSettingsCubit(
          gh<_i456.GetOwnerPrintingSettingsUseCase>(),
          gh<_i602.SaveOwnerPrintingSettingsUseCase>(),
        ));
    gh.factory<_i317.FetchClinicByIdCubit>(
        () => _i317.FetchClinicByIdCubit(gh<_i665.FetchClinicByIdUseCase>()));
    gh.factory<_i116.PatientDetailsCubit>(() => _i116.PatientDetailsCubit(
          gh<_i338.FindPatientByIdUseCase>(),
          gh<_i507.GetVisitsForPatientUseCase>(),
        ));
    gh.factory<_i174.DoctorPerformanceCubit>(() =>
        _i174.DoctorPerformanceCubit(gh<_i397.GetDoctorPerformanceUseCase>()));
    gh.factory<_i795.InvoicesCubit>(() => _i795.InvoicesCubit(
          gh<_i366.GetInvoicesUseCase>(),
          gh<_i920.CreateInvoiceUseCase>(),
          gh<_i1072.UpdateInvoiceUseCase>(),
          gh<_i109.DeleteInvoiceUseCase>(),
          gh<_i289.GetPatientUnpaidAppointmentsUseCase>(),
          gh<_i338.FindPatientByIdUseCase>(),
          gh<_i209.GetAppointmentByIdUseCase>(),
          gh<_i986.LoadPatientsUseCase>(),
        ));
    gh.factory<_i753.ClinicReportsCubit>(
        () => _i753.ClinicReportsCubit(gh<_i1007.GetClinicReportUseCase>()));
    gh.factory<_i405.DrugReportsCubit>(
        () => _i405.DrugReportsCubit(gh<_i965.GetDrugStatsUseCase>()));
    gh.factory<_i977.FinancialReportsCubit>(() =>
        _i977.FinancialReportsCubit(gh<_i249.GetRevenueSummaryUseCase>()));
    gh.factory<_i169.ClinicsCubit>(() => _i169.ClinicsCubit(
          fetchClinicsUseCase: gh<_i236.FetchClinicsUseCase>(),
          addClinicUseCase: gh<_i747.AddClinicUseCase>(),
          editClinicUseCase: gh<_i240.EditClinicUseCase>(),
          deleteClinicUseCase: gh<_i2.DeleteClinicUseCase>(),
          toggleIsActiveUseCase: gh<_i444.ToggleIsActiveUseCase>(),
          addStaffUseCase: gh<_i25.AddStaffUseCase>(),
          deleteStaffUseCase: gh<_i382.DeleteStaffUseCase>(),
        ));
    gh.factory<_i476.AppointmentReportsCubit>(() =>
        _i476.AppointmentReportsCubit(gh<_i660.GetAppointmentStatsUseCase>()));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
