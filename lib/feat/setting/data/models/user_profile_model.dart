import 'package:safetrek_project/feat/setting/domain/entity/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
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

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
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
}
