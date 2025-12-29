import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';

/// Lớp triển khai cụ thể của AuthRepository, sử dụng Firebase Authentication.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Auth
      // Ví dụ: user-not-found, wrong-password
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Auth
      // Ví dụ: email-already-in-use, weak-password
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Lỗi đăng xuất. Vui lòng thử lại.');
    }
  }
}
