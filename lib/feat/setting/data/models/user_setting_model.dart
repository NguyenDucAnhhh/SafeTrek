import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

class UserSettingModel extends UserSetting {
  const UserSettingModel({
    required String name,
    required String email,
    required String phone,
    required String safePIN,
    required String duressPIN,
  }) : super(
          name: name,
          email: email,
          phone: phone,
          safePIN: safePIN,
          duressPIN: duressPIN,
        );

  factory UserSettingModel.fromMap(Map<String, dynamic> map) {
    return UserSettingModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      safePIN: map['safePIN'] ?? '',
      duressPIN: map['duressPIN'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'safePIN': safePIN,
      'duressPIN': duressPIN,
    };
  }

  factory UserSettingModel.fromEntity(UserSetting entity) {
    return UserSettingModel(
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      safePIN: entity.safePIN,
      duressPIN: entity.duressPIN,
    );
  }
}
