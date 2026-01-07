import 'package:firebase_auth/firebase_auth.dart';
import '../repository/user_repository.dart';
import '../repository/auth_repository.dart';

/// Usecase để đăng ký: tạo tài khoản trên Firebase Auth,
/// sau đó lưu document user vào Firestore với id = uid.
class RegisterUser {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  RegisterUser(this._authRepository, this._userRepository);

  /// [additionalData] có thể chứa tên, phone, ...
  Future<void> call(String email, String password, Map<String, dynamic>? additionalData) async {
    try {
      await _authRepository.signUpWithEmailAndPassword(email: email, password: password);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      final uid = firebaseUser?.uid;
      if (uid == null) throw Exception('Không lấy được uid sau khi đăng ký');

      final mapData = <String, dynamic>{};
      if (additionalData != null) mapData.addAll(additionalData);
      mapData['email'] = email;

      try {
        await _userRepository.createUser(uid, mapData);
      } catch (e) {
        // rollback: xóa auth nếu không lưu được vào Firestore
        try {
          await firebaseUser!.delete();
        } catch (_) {}
        // cũng có thể xóa doc nếu một phần nào đó đã được tạo, nhưng ở đây set thất bại nên bỏ qua
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
