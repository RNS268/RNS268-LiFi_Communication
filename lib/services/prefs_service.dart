import 'package:esp8266_controller_app/services/user_preferences_service.dart';

class PrefsService {
  PrefsService({UserPreferencesService? prefs})
      : _prefs = prefs ?? UserPreferencesService();

  final UserPreferencesService _prefs;

  Future<void> setUserName(String name) => _prefs.setUserName(name);
  Future<String?> getUserName() => _prefs.getUserName();

  Future<void> setUserAge(int age) => _prefs.setUserAge(age);
  Future<int?> getUserAge() => _prefs.getUserAge();

  Future<void> setThemeMode(String mode) => _prefs.setThemeMode(mode);
  Future<String> getThemeMode() => _prefs.getThemeMode();
}

