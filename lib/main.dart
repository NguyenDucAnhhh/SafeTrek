import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feat/auth/data/repository/auth_repository_impl.dart';
import 'feat/auth/domain/repository/auth_repository.dart';
import 'feat/auth/presentation/bloc/auth_bloc.dart'; // Đổi từ cubit sang bloc
import 'feat/auth/presentation/auth_wrapper.dart'; // Sử dụng AuthWrapper
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(FirebaseAuth.instance),
      child: BlocProvider<AuthBloc>( // Đổi từ AuthCubit sang AuthBloc
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeTrek',
          // AuthWrapper sẽ tự động điều hướng dựa trên trạng thái của AuthBloc
          home: AuthWrapper(), 
        ),
      ),
    );
  }
}
