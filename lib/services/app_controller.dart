import 'package:flutter/material.dart';

import 'package:esp8266_controller_app/services/prefs_service.dart';

class AppController {
  AppController._();

  static final AppController instance = AppController._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);
  final ValueNotifier<int> currentTabIndex = ValueNotifier<int>(0);

  final PrefsService _prefs = PrefsService();

  Future<void> loadThemeMode() async {
    final raw = await _prefs.getThemeMode();
    themeMode.value = _stringToThemeMode(raw);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setThemeMode(mode);
    themeMode.value = _stringToThemeMode(mode);
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode.trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

