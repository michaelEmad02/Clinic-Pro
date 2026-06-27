import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة حقن الاعتماديات (Dependency Injection)
  configureDependencies();
  
  runApp(const ClinicPro());
}

class ClinicPro extends StatelessWidget {
  const ClinicPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClinicPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
