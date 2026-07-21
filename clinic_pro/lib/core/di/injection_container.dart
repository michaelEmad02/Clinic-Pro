import 'package:clinic_pro/features/settings/domain/usecases/get_doctor_schedules_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/upsert_doctor_schedule_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/domain/usecases/get_doctor_appointment_types_usecase.dart';
import '../../features/settings/domain/usecases/get_global_appointment_types_usecase.dart';
import '../../features/settings/domain/usecases/get_queue_rule_usecase.dart';
import '../../features/settings/domain/usecases/sync_doctor_appointment_types_usecase.dart';
import '../../features/settings/domain/usecases/upsert_queue_rule_usecase.dart';
import '../../features/settings/presentation/manager/queue_pattern_cubit.dart';
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

  // تسجيل حالات الاستخدام (UseCases) الجديدة يدوياً
  sl.registerFactory(
      () => SyncDoctorAppointmentTypesUseCase(sl<ISettingsRepository>()));
  sl.registerFactory(
      () => GetGlobalAppointmentTypesUseCase(sl<ISettingsRepository>()));
  sl.registerFactory(
      () => GetDoctorSchedulesUseCase(sl<ISettingsRepository>()));
  sl.registerFactory(
      () => UpsertDoctorScheduleUseCase(sl<ISettingsRepository>()));

  sl.registerFactory(() => QueuePatternCubit(
        sl<GetQueueRuleUseCase>(),
        sl<UpsertQueueRuleUseCase>(),
        sl<GetDoctorAppointmentTypesUseCase>(),
        sl<GetGlobalAppointmentTypesUseCase>(),
      ));
  sl.registerFactory(() => VisitTypesCubit(
        sl<GetDoctorAppointmentTypesUseCase>(),
        sl<GetGlobalAppointmentTypesUseCase>(),
        sl<SyncDoctorAppointmentTypesUseCase>(),
      ));
  sl.registerFactory(() => WorkingHoursCubit(
        sl<GetDoctorSchedulesUseCase>(),
        sl<UpsertDoctorScheduleUseCase>(),
      ));
}
