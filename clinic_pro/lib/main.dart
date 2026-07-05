import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/manager/auth_cubit.dart';
import 'features/onboarding/presentation/manager/onboarding_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة حقن الاعتماديات (Dependency Injection)
  configureDependencies();
  await sl.allReady();

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
      ],
      child: MaterialApp.router(
        title: 'ClinicPro',
        debugShowCheckedModeBanner: false,
        // تفعيل اللغة العربية واتجاه RTL على مستوى التطبيق
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
