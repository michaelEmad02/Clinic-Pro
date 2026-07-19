import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';
import 'core/services/deep_link_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/manager/auth_cubit.dart';
import 'features/onboarding/presentation/manager/onboarding_cubit.dart';

import 'core/themes/theme_cubit.dart';
import 'core/localization/language_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// تهئية supabase
  await Supabase.initialize(
    url: "https://sybsvobonipnmvymauvc.supabase.co",
    publishableKey: "sb_publishable_PHmN-KnBgnhDYISy7wBNPA_U4mfPLba",
  );
  // تهيئة حقن الاعتماديات (Dependency Injection)
  await configureDependencies();
  await sl.allReady();

  // تهيئة خدمة الروابط العميقة (Deep Links) لالتقاط روابط الدعوات
  final deepLinkService = DeepLinkService(appRouter);
  deepLinkService.init();

  runApp(const ClinicPro());
}

class ClinicPro extends StatelessWidget {
  const ClinicPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<OnboardingCubit>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LanguageCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                key: ValueKey(locale.languageCode),
                title: 'ClinicPro',
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
