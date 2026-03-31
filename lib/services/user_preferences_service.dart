import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _userNameKey = 'user_name';
  static const String _userAgeKey = 'user_age';
  static const String _themeModeKey = 'theme_mode';

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> setUserAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userAgeKey, age);
  }

  Future<int?> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userAgeKey);
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeThemeMode(mode);
    await prefs.setString(_themeModeKey, normalized);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return _normalizeThemeMode(prefs.getString(_themeModeKey) ?? 'system');
  }

  String _normalizeThemeMode(String mode) {
    switch (mode.trim().toLowerCase()) {
      case 'light':
      case 'dark':
      case 'system':
        return mode.trim().toLowerCase();
      default:
        return 'system';
    }
  }
}

