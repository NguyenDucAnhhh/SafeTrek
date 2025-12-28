import 'package:safetrek_project/feat/setting/data/datasource/setting_remote_data_source.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserSetting> getUserSettings() async {
    return await remoteDataSource.getUserSettings();
  }

  @override
  Future<void> updateProfile(String name, String phone) async {
    return await remoteDataSource.updateProfile(name: name, phone: phone);
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
}
