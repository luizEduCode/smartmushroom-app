import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/src/core/di/app_dependencies.dart';
import 'package:smartmushroom_app/src/core/theme/app_theme.dart';
import 'package:smartmushroom_app/src/core/theme/theme_notifier.dart';
import 'package:smartmushroom_app/src/features/auth/presentation/pages/splash_screen.dart';

class SmartMushroomApp extends StatelessWidget {
  const SmartMushroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.instance;
    return ChangeNotifierProvider.value(
      value: dependencies.themeViewModel,
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SmartMushroom',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
