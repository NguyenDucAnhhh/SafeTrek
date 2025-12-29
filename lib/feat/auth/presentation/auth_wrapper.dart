import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/auth/presentation/cubit/auth_cubit.dart';
import 'package:safetrek_project/feat/auth/presentation/cubit/auth_state.dart';
import 'package:safetrek_project/feat/home/presentation/login/login.dart';
import 'package:safetrek_project/feat/home/presentation/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Nếu người dùng đã đăng nhập, hiển thị màn hình chính
          return const MainScreen();
        } else if (state is Unauthenticated) {
          // Nếu chưa đăng nhập, hiển thị màn hình đăng nhập
          return const LoginScreen();
        }
        // Trong lúc đang kiểm tra, hiển thị màn hình chờ
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
            ),
          ),
        );
      },
    );
  }
}
