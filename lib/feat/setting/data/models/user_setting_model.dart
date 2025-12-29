import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/feat/setting/domain/entity/user_setting.dart';

class UserSettingModel extends UserSetting {
  const UserSettingModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.safePIN,
    required super.duressPIN,
  });

  /// Tạo từ DocumentSnapshot của Firestore
  factory UserSettingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserSettingModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      safePIN: data['safePIN'] ?? '',
      duressPIN: data['duressPIN'] ?? '',
    );
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'safePIN': safePIN,
      'duressPIN': duressPIN,
    };
  }

  /// Chuyển từ entity
  factory UserSettingModel.fromEntity(UserSetting entity) {
    return UserSettingModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      safePIN: entity.safePIN,
      duressPIN: entity.duressPIN,
    );
  }
}
