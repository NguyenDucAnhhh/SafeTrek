import 'package:safetrek_project/feat/setting/data/datasource/setting_remote_data_source.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';
import '../datasource/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ===== REMOTE (Firebase) =====
  @override
  Future<UserSetting> getUserSettings() async {
    return await remoteDataSource.getUserSettings();
  }

  @override
  Future<void> updateProfile(String name, String phone, String email) async {
    return await remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<void> changeSafePin(String pin) async {
    return await remoteDataSource.updateSafePin(pin);
  }

  @override
  Future<void> changeDuressPin(String pin) async {
    return await remoteDataSource.updateDuressPin(pin);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    return await remoteDataSource.changePassword(oldPassword, newPassword);
  }

  // ===== LOCAL (Hidden Panic) =====
  @override
  Future<bool> getHiddenPanic() {
    return localDataSource.getHiddenPanic();
  }

  @override
  Future<void> setHiddenPanic(bool enabled) {
    return localDataSource.setHiddenPanic(enabled);
  }
}
