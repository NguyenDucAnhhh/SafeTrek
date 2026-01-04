import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveHiddenPanicSettings(bool isEnabled, String method, int pressCount);
  Future<Map<String, dynamic>> loadHiddenPanicSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  static const String _isEnabledKey = 'hiddenPanic_isEnabled';
  static const String _methodKey = 'hiddenPanic_method';
  static const String _pressCountKey = 'hiddenPanic_pressCount';

  @override
  Future<void> saveHiddenPanicSettings(bool isEnabled, String method, int pressCount) async {
    await sharedPreferences.setBool(_isEnabledKey, isEnabled);
    await sharedPreferences.setString(_methodKey, method);
    await sharedPreferences.setInt(_pressCountKey, pressCount);
  }

  @override
  Future<Map<String, dynamic>> loadHiddenPanicSettings() async {
    return {
      'isEnabled': sharedPreferences.getBool(_isEnabledKey) ?? false,
      'method': sharedPreferences.getString(_methodKey) ?? 'volume',
      'pressCount': sharedPreferences.getInt(_pressCountKey) ?? 5,
    };
  }
}
