import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    
    // 1. Lắng nghe thay đổi trạng thái từ Firebase Auth (Token thay đổi)
    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthStatusChanged(user)),
    );

    // 2. Xử lý khi trạng thái Auth thay đổi (Token có hoặc mất)
    on<AuthStatusChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user as User));
      } else {
        emit(Unauthenticated());
      }
    });

    // 3. Xử lý sự kiện Đăng nhập
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signInWithEmailAndPassword(
          email: event.email, 
          password: event.password
        );
        // Trạng thái Authenticated sẽ tự động được phát ra bởi listener ở trên
      } catch (e) {
        emit(AuthFailure(e.toString()));
        // Quay lại trạng thái chưa đăng nhập sau khi báo lỗi
        await Future.delayed(const Duration(seconds: 1));
        emit(Unauthenticated());
      }
    });

    // 4. Xử lý sự kiện Đăng ký
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Tạo tài khoản Auth
        await _authRepository.signUpWithEmailAndPassword(
          email: event.email, 
          password: event.password
        );

        // Lưu thông tin bổ sung vào Firestore
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
            'name': event.name,
            'phone': event.phone,
            'email': event.email,
            'safePIN': null,
            'duressPIN': null,
          });
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        await Future.delayed(const Duration(seconds: 1));
        emit(Unauthenticated());
      }
    });

    // 5. Xử lý sự kiện Đăng xuất
    on<LogoutRequested>((event, emit) async {
      try {
        await _authRepository.signOut();
        // Unauthenticated sẽ được phát ra bởi listener
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
