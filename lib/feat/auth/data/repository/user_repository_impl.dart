import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin người dùng: $e');
    }
  }

  @override
  Future<void> deleteUserDocument(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      // ignore errors on delete during rollback
    }
  }
}
