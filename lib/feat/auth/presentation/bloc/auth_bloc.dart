import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/auth/domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/register_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final RegisterUser _registerUser;
  StreamSubscription<User?>? _userSubscription;
  AuthBloc({required AuthRepository authRepository, required RegisterUser registerUser}) : _authRepository = authRepository, _registerUser = registerUser, super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UserChanged>(_onUserChanged);

    _userSubscription = _authRepository.user.listen((user) {
      add(UserChanged(user));
    });
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(email: event.email, password: event.password);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _registerUser.call(event.email, event.password, event.additionalData);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
  }
  
  void _onUserChanged(UserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
