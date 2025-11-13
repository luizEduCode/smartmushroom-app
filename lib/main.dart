import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:smartmushroom_app/core/theme/app_theme.dart';
import 'package:smartmushroom_app/core/theme/theme_notifier.dart';
import 'package:smartmushroom_app/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await GetStorage.init();
  runApp(const SmartMushroomApp());
}

class SmartMushroomApp extends StatelessWidget {
  const SmartMushroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeViewModel(),
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SmartMushroom',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.themeMode,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
