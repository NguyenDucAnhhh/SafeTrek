import 'package:firebase_auth/firebase_auth.dart';

/// Hợp đồng trừu tượng cho lớp Repository của tính năng Authentication.
/// Lớp này định nghĩa CÁC CHỨC NĂNG cần có, không quan tâm đến cách triển khai.
abstract class AuthRepository {
  /// Trả về stream của User hiện tại để lắng nghe thay đổi trạng thái đăng nhập.
  Stream<User?> get user;

  /// Đăng nhập bằng email và password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới bằng email và password.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Đăng xuất người dùng hiện tại.
  Future<void> signOut();
}
