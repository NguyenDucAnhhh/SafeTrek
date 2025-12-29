import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feat/auth/data/repository/auth_repository_impl.dart';
import 'feat/auth/domain/repository/auth_repository.dart';
import 'feat/auth/presentation/cubit/auth_cubit.dart';
import 'feat/auth/presentation/auth_wrapper.dart';
import 'firebase_options.dart'; // Import your Firebase options

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
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeTrek',
          // AuthWrapper sẽ quyết định hiển thị màn hình nào
          home: AuthWrapper(), 
        ),
      ),
    );
  }
}
