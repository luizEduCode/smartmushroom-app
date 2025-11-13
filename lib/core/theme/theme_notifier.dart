import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({GetStorage? storage}) : _storage = storage ?? GetStorage() {
    final savedMode = _storage.read<String>(_themeKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  static const String _themeKey = 'theme_mode';
  final GetStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      updateThemeMode(ThemeMode.light);
    } else {
      updateThemeMode(ThemeMode.dark);
    }
  }

  void updateThemeMode(ThemeMode value) {
    if (_themeMode == value) return;
    _themeMode = value;
    _storage.write(_themeKey, value.name);
    notifyListeners();
  }
}
