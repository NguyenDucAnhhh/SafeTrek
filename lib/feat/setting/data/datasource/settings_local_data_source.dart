import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<bool> getHiddenPanic();
  Future<void> setHiddenPanic(bool enabled);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const _keyHiddenPanic = 'hidden_panic_enabled';

  @override
  Future<bool> getHiddenPanic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHiddenPanic) ?? false;
  }

  @override
  Future<void> setHiddenPanic(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHiddenPanic, enabled);
  }
}
