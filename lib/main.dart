import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'feat/home/presentation/splash/splash_screen.dart';
import 'firebase_options.dart';

// AUTH
import 'feat/auth/data/repository/auth_repository_impl.dart';
import 'feat/auth/domain/repository/auth_repository.dart';
import 'feat/auth/presentation/bloc/auth_bloc.dart';

// SETTINGS
import 'feat/setting/domain/repository/settings_repository.dart';
import 'feat/setting/data/datasource/setting_remote_data_source.dart';
import 'feat/setting/data/datasource/settings_local_data_source.dart';
import 'feat/setting/data/repository/setting_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ================= SETTINGS DATA =================
  final settingsRemoteDataSource = SettingsRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

  final settingsLocalDataSource = SettingsLocalDataSourceImpl();

  final settingsRepository = SettingsRepositoryImpl(
    remoteDataSource: settingsRemoteDataSource,
    localDataSource: settingsLocalDataSource,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuth.instance),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => settingsRepository,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        // 👉 Nếu sau này SettingsBloc cần global, thêm ở đây
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SafeTrek',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
