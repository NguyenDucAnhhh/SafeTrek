import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/core/error/exceptions.dart';
import '../models/user_setting_model.dart';

abstract class SettingsRemoteDataSource {
  Future<UserSettingModel> getUserSettings();
  Future<void> updateProfile({required String name, required String phone});
  Future<void> updateSafePin(String pin);
  Future<void> updateDuressPin(String pin);
  Future<void> changePassword(String oldPassword, String newPassword);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SettingsRemoteDataSourceImpl({required this.firestore, required this.auth});

  final String _testUserId = 'fBMzuk8GwEjeqccc1j54';

  String get _currentUserId {
    return auth.currentUser?.uid ?? _testUserId;
  }

  @override
  Future<UserSettingModel> getUserSettings() async {
    try {
      final docSnapshot = await firestore.collection('users').doc(_currentUserId).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        print('Fetched data for user: $_currentUserId');
        return UserSettingModel.fromMap(docSnapshot.data()!);
      } else {
        print('User document not found for id: $_currentUserId');
        throw ServerException();
      }
    } catch (e) {
      print('Error fetching user settings: $e');
      throw ServerException();
    }
  }

  @override
  Future<void> updateProfile({required String name, required String phone}) async {
    if (auth.currentUser == null) return;
    await firestore.collection('users').doc(_currentUserId).update({
      'name': name,
      'phone': phone,
    });
  }

  @override
  Future<void> updateSafePin(String pin) async {
    if (auth.currentUser == null) return;
    await firestore.collection('users').doc(_currentUserId).update({
      'safePIN': pin,
    });
  }

  @override
  Future<void> updateDuressPin(String pin) async {
    if (auth.currentUser == null) return;
    await firestore.collection('users').doc(_currentUserId).update({
      'duressPIN': pin,
    });
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = auth.currentUser;
    if (user == null) throw ServerException();

    final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }
}
