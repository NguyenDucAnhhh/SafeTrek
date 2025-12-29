import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kiểm tra trạng thái xác thực khi khởi động ứng dụng
class AuthStatusChanged extends AuthEvent {
  final dynamic user; // Kiểu User từ firebase_auth

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Sự kiện đăng nhập
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Sự kiện đăng ký
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, phone];
}

/// Sự kiện đăng xuất
class LogoutRequested extends AuthEvent {}
