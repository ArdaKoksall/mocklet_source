import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app/service/pref_service.dart';

import '../../app_logger.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService() {
    init();
  }

  void init() {
    _themeMode = loadThemeMode();
    AppLogger.info("Theme mode initialized: $_themeMode");
  }

  ThemeMode loadThemeMode() {
    final themeString = PrefService.themeString;
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await PrefService.setThemeMode(mode.toString().split('.').last);
      notifyListeners();
    }
  }
}

final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  return ThemeService();
});
