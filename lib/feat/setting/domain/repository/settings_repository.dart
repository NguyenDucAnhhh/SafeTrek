import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

abstract class SettingsRepository {
  Future<UserSetting> getUserSettings();
  Future<void> updateProfile(String name, String phone, String email);
  Future<void> changeSafePin(String pin);
  Future<void> changeDuressPin(String pin);
  Future<void> changePassword(String oldPassword, String newPassword);

  // Methods for Hidden Panic
  Future<void> saveHiddenPanicSettings(bool isEnabled, String method, int pressCount);
  Future<Map<String, dynamic>> loadHiddenPanicSettings();
}
