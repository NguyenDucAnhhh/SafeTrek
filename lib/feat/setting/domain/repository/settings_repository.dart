import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

abstract class SettingsRepository {
  Future<UserSetting> getUserSettings();
  Future<void> updateProfile(String name, String phone, String email);
  Future<void> changeSafePin(String pin);
  Future<void> changeDuressPin(String pin);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<bool> getHiddenPanic();
  Future<void> setHiddenPanic(bool enabled);
}
