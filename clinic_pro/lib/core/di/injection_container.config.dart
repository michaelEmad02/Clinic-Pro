// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/presentation/manager/auth_cubit.dart' as _i888;
import '../../features/onboarding/presentation/manager/onboarding_cubit.dart'
    as _i1012;
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
    gh.factory<_i888.AuthCubit>(
        () => _i888.AuthCubit(gh<_i239.ICloudService>()));
    return this;
  }
}
