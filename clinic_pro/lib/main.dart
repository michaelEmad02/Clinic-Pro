import 'dart:async';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/services/i_network_info.dart';
import 'core/strings/app_strings.dart';
import 'core/themes/app_theme.dart';
import 'core/services/app_initializer.dart';
import 'core/widgets/app_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/manager/auth_cubit.dart';
import 'features/onboarding/presentation/manager/onboarding_cubit.dart';
import 'core/themes/theme_cubit.dart';
import 'core/localization/language_cubit.dart';
import 'features/settings/presentation/manager/settings_cubit.dart';

void main() async {
  // تهيئة جميع خدمات التطبيق قبل الإقلاع
  await AppInitializer.init();

  runApp(const ClinicPro());
}

class ClinicPro extends StatefulWidget {
  const ClinicPro({super.key});

  @override
  State<ClinicPro> createState() => _ClinicProState();
}

class _ClinicProState extends State<ClinicPro> {
  StreamSubscription<bool>? _networkSubscription;
  bool _isFirstCheck = true;

  @override
  void initState() {
    super.initState();
    _listenToNetworkChanges();
  }

  void _listenToNetworkChanges() {
    final networkInfo = sl<INetworkInfo>();
    _networkSubscription = networkInfo.onConnectivityChanged.listen((isConnected) {
      if (_isFirstCheck) {
        _isFirstCheck = false;
        if (!isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNoInternetNotification();
          });
        }
        return;
      }

      if (!isConnected) {
        _showNoInternetNotification();
      } else {
        _showInternetRestoredNotification();
      }
    });
  }

  void _showNoInternetNotification() {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      AppSnackbar.error(
        context,
        message: AppStrings.noInternetConnection,
      );
    }
  }

  void _showInternetRestoredNotification() {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      AppSnackbar.success(
        context,
        message: AppStrings.internetRestored,
      );
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<OnboardingCubit>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LanguageCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                key: ValueKey(locale.languageCode),
                title: 'Clinic Pro',
                debugShowCheckedModeBanner: false,
                // تفعيل اللغة المختارة واتجاه RTL/LTR تلقائياً
                locale: locale,
                supportedLocales: const [Locale('ar'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}
