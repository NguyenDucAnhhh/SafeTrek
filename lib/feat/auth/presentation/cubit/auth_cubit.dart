import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _userSubscription = _authRepository.user.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(email: email, password: password);
      // Trạng thái Authenticated sẽ được phát ra bởi stream listener ở trên
    } catch (e) {
      emit(AuthError(e.toString()));
      // Sau khi báo lỗi, quay lại trạng thái chưa xác thực
      Future.delayed(const Duration(seconds: 2), () => emit(Unauthenticated()));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmailAndPassword(email: email, password: password);
      // Trạng thái Authenticated sẽ được phát ra bởi stream listener ở trên
    } catch (e) {
      emit(AuthError(e.toString()));
      Future.delayed(const Duration(seconds: 2), () => emit(Unauthenticated()));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
