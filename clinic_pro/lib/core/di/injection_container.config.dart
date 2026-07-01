// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:clinic_pro/features/patients/presentation/manager/patients_cubit.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patients_repository.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/drugs_cubit.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/templates_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/manager/auth_cubit.dart';
import '../../features/onboarding/presentation/manager/onboarding_cubit.dart';
import '../../features/prescription/presentation/manager/prescription_bloc.dart';
import '../services/i_cloud_service.dart';
import '../services/mock_cloud_service.dart';

extension GetItInjectableX on GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  GetIt init({
    String? environment,
    EnvironmentFilter? environmentFilter,
  }) {
    final gh = GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<OnboardingCubit>(() => OnboardingCubit());
    gh.lazySingleton<ICloudService>(() => MockCloudService());
    gh.factory<TemplatesCubit>(() => TemplatesCubit(gh<ICloudService>()));
    gh.factory<DrugsCubit>(() => DrugsCubit(gh<ICloudService>()));
    gh.factory<AuthCubit>(() => AuthCubit(gh<ICloudService>()));
    gh.factory<PrescriptionBloc>(() => PrescriptionBloc(gh<ICloudService>()));
    gh.factory<PatientsRepository>(() => PatientsRepository(gh<ICloudService>()));
    gh.factory<PatientsCubit>(() => PatientsCubit(gh<PatientsRepository>()));
    return this;
  }
}
