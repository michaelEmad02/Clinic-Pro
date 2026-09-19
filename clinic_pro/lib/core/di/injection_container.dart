import 'package:clinic_pro/core/services/ai/ai_edge_function_service.dart';
import 'package:clinic_pro/core/services/ai/ai_voice_extraction_service_impl.dart';
import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:clinic_pro/core/services/voice_extraction_mode_service.dart';
import 'package:clinic_pro/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_ai_settings_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/save_ai_settings_usecase.dart';
import 'package:clinic_pro/features/settings/presentation/manager/ai_settings_cubit.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_doctor_schedules_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/upsert_doctor_schedule_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.config.dart';
import '../../features/settings/domain/usecases/get_doctor_appointment_types_usecase.dart';
import '../../features/settings/domain/usecases/get_global_appointment_types_usecase.dart';
import '../../features/settings/domain/usecases/sync_doctor_appointment_types_usecase.dart';
import '../../features/settings/presentation/manager/visit_types_cubit.dart';
import '../../features/settings/presentation/manager/working_hours_cubit.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await sl.init();

  // sl.registerFactory(() => QueuePatternCubit(
  //       sl<GetQueueRuleUseCase>(),
  //       sl<UpsertQueueRuleUseCase>(),
  //       sl<GetDoctorAppointmentTypesUseCase>(),
  //       sl<GetGlobalAppointmentTypesUseCase>(),
  //     ));
  sl.registerFactory(() => VisitTypesCubit(
        sl<GetDoctorAppointmentTypesUseCase>(),
        sl<GetGlobalAppointmentTypesUseCase>(),
        sl<SyncDoctorAppointmentTypesUseCase>(),
      ));
  sl.registerFactory(() => WorkingHoursCubit(
        sl<GetDoctorSchedulesUseCase>(),
        sl<UpsertDoctorScheduleUseCase>(),
      ));

  // ─── AI Voice Extraction & Settings ───
  if (!sl.isRegistered<RegexVoiceExtractionServiceImpl>()) {
    sl.registerLazySingleton<RegexVoiceExtractionServiceImpl>(
        () => RegexVoiceExtractionServiceImpl());
  }

  if (!sl.isRegistered<AiEdgeFunctionService>()) {
    sl.registerLazySingleton<AiEdgeFunctionService>(
        () => AiEdgeFunctionService(sl<SupabaseClient>()));
  }

  if (!sl.isRegistered<AiVoiceExtractionServiceImpl>()) {
    sl.registerLazySingleton<AiVoiceExtractionServiceImpl>(
        () => AiVoiceExtractionServiceImpl(
              sl<AiEdgeFunctionService>(),
              sl<IAuthRepository>(),
            ));
  }

  if (!sl.isRegistered<GetAiSettingsUseCase>()) {
    sl.registerLazySingleton<GetAiSettingsUseCase>(
        () => GetAiSettingsUseCase(sl<IOwnerSettingsRepository>()));
  }

  if (!sl.isRegistered<SaveAiSettingsUseCase>()) {
    sl.registerLazySingleton<SaveAiSettingsUseCase>(
        () => SaveAiSettingsUseCase(sl<IOwnerSettingsRepository>()));
  }

  if (!sl.isRegistered<AiSettingsCubit>()) {
    sl.registerFactory<AiSettingsCubit>(
        () => AiSettingsCubit(
              sl<GetAiSettingsUseCase>(),
              sl<SaveAiSettingsUseCase>(),
              sl<AiEdgeFunctionService>(),
            ));
  }

  // VoiceExtractionModeService acts as the primary IVoiceExtractionService
  if (sl.isRegistered<IVoiceExtractionService>()) {
    sl.unregister<IVoiceExtractionService>();
  }
  sl.registerLazySingleton<IVoiceExtractionService>(
      () => VoiceExtractionModeService(
            sl<RegexVoiceExtractionServiceImpl>(),
            sl<AiVoiceExtractionServiceImpl>(),
            sl<IOwnerSettingsRepository>(),
            sl<IAuthRepository>(),
          ));
}
