import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/core/error/exceptions.dart';
import '../models/user_setting_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingModel> getUserSettings();
  Future<void> updateProfile({required String name, required String phone, required String email});
  Future<void> updateSafePin(String pin);
  Future<void> updateDuressPin(String pin);
  Future<void> changePassword(String oldPassword, String newPassword);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SettingsRemoteDataSourceImpl({required this.firestore, required this.auth});

  final String _testUserId = 'q8lguH9oniXKz47UmMXEBRc1URS2';

  String get _currentUserId {
    return auth.currentUser?.uid ?? _testUserId;
  }

  // @override
  // Future<UserSettingModel> getUserSettings() async {
  //   try {
  //     final docSnapshot = await firestore.collection('users').doc(_currentUserId).get();
  //
  //     if (docSnapshot.exists && docSnapshot.data() != null) {
  //       print('Fetched data for user: $_currentUserId');
  //       return UserSettingModel.fromMap(docSnapshot.data()!);
  //     } else {
  //       print('User document not found for id: $_currentUserId');
  //       throw ServerException();
  //     }
  //   } catch (e) {
  //     print('Error fetching user settings: $e');
  //     throw ServerException();
  //   }
  // }

  @override
  Future<UserSettingModel> getUserSettings() async {
    try {
      final docSnapshot =
      await firestore.collection('users').doc(_currentUserId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        print('Fetched Firestore data for user: $_currentUserId');
        // Sử dụng fromFirestore thay vì fromMap
        return UserSettingModel.fromFirestore(docSnapshot);
      }

      // ================= FALLBACK TEST DATA =================
      print('Using FAKE user settings for testing');
      return UserSettingModel(
        userId: _currentUserId,
        name: 'Nguyễn Đức Anh (Test)',
        email: 'ab@gmail.com',
        phone: '0987654321',
        safePIN: '1234',
        duressPIN: '9999',
      );
    } catch (e) {
      print('Error fetching user settings: $e');

      // ================= SAFETY FALLBACK =================
      return UserSettingModel(
        userId: _currentUserId,
        name: 'Test User',
        email: 'a@gmail.com',
        phone: '0000000000',
        safePIN: '1111',
        duressPIN: '9999',
      );
    }
  }

  @override
  Future<void> updateProfile({required String name, required String phone, required String email}) async {
    await firestore.collection('users').doc(_currentUserId).update({
      'name': name,
      'phone': phone,
      'email': email,
    });
  }

  @override
  Future<void> updateSafePin(String pin) async {
    await firestore.collection('users').doc(_currentUserId).update({
      'safePIN': pin,
    });
  }

  @override
  Future<void> updateDuressPin(String pin) async {
    await firestore.collection('users').doc(_currentUserId).update({
      'duressPIN': pin,
    });
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = auth.currentUser;
    if (user == null || user.email == null) throw Exception("Người dùng chưa đăng nhập");

    try {
      // 1. Tạo "Credential" từ mật khẩu cũ
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      // 2. Xác thực lại (Bắt buộc của Firebase)
      await user.reauthenticateWithCredential(credential);

      // 3. Cập nhật mật khẩu mới
      await user.updatePassword(newPassword);

      //  4. SIGN OUT để ổn định auth state
      await auth.signOut();

      print("Firebase Authen: Đổi mật khẩu thành công!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception("Mật khẩu cũ không chính xác");
      } else if (e.code == 'weak-password') {
        throw Exception("Mật khẩu mới quá yếu");
      }
      throw Exception(e.message);
    }
  }

}
