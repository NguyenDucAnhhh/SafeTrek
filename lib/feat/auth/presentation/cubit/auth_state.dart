import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu, chưa xác thực
class AuthInitial extends AuthState {}

/// Trạng thái đang xử lý (ví dụ: đang nhấn nút đăng nhập)
class AuthLoading extends AuthState {}

/// Trạng thái đã xác thực thành công
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Trạng thái chưa xác thực
class Unauthenticated extends AuthState {}

/// Trạng thái có lỗi xảy ra
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
