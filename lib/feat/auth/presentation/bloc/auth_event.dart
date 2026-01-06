import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => []; // Thay đổi ở đây: Object -> Object?
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final Map<String, dynamic>? additionalData; // ex: name, phone, etc.

  const SignUpRequested({required this.email, required this.password, this.additionalData});

  @override
  List<Object?> get props => [email, password, additionalData];
}

class SignOutRequested extends AuthEvent {}

class UserChanged extends AuthEvent {
  final User? user;

  const UserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
