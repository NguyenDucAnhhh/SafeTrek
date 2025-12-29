import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class AuthInitial extends AuthState {}

/// Đang xử lý (đang đăng nhập hoặc đăng ký)
class AuthLoading extends AuthState {}

/// Đã xác thực thành công
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Chưa xác thực hoặc đã đăng xuất
class Unauthenticated extends AuthState {}

/// Có lỗi xảy ra
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
