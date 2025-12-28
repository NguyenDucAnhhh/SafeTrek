import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

abstract class SettingsRepository {
  Future<UserSetting> getUserSettings();
  Future<void> updateProfile(String name, String phone);
  Future<void> changeSafePin(String pin);
  Future<void> changeDuressPin(String pin);
  Future<void> changePassword(String oldPassword, String newPassword);
}
