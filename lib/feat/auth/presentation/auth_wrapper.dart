import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_state.dart';
import '../../home/presentation/login/login.dart';
import '../../home/presentation/main_screen.dart';
import '../../home/presentation/splash/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Nếu đã đăng nhập -> Vào màn hình chính
          return const MainScreen();
        } else if (state is Unauthenticated || state is AuthFailure) {
          // Nếu chưa đăng nhập hoặc lỗi -> Vào màn hình Login
          return const LoginScreen();
        } else if (state is AuthInitial || state is AuthLoading) {
          // Trong lúc khởi động hoặc đang xử lý -> Hiện màn hình Splash/Chờ
          return const SplashScreen();
        }
        
        // Mặc định trả về Splash
        return const SplashScreen();
      },
    );
  }
}
