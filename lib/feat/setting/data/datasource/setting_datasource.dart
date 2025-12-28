import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/core/error/exceptions.dart';
import 'package:safetrek_project/feat/setting/data/models/user_profile_model.dart';

abstract class SettingDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<void> updateUserProfile(UserProfileModel userProfile);
}

class SettingDataSourceImpl implements SettingDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  SettingDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<UserProfileModel> getUserProfile() async {
    final user = auth.currentUser;
    if (user == null) throw ServerException();

    try {
      final docSnapshot = await firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        return UserProfileModel.fromMap(docSnapshot.data()!);
      } else {
        throw ServerException(); // hoặc một exception khác tùy logic của bạn
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateUserProfile(UserProfileModel userProfile) async {
    final user = auth.currentUser;
    if (user == null) throw ServerException();

    try {
      await firestore.collection('users').doc(user.uid).update(userProfile.toMap());
    } catch (e) {
      throw ServerException();
    }
  }
}
