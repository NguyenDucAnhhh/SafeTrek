import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'background_service.dart';

// UI
import 'feat/home/presentation/splash/splash_screen.dart';
import 'panic/panic_listener.dart';

// ================= AUTH =================
import 'feat/auth/data/repository/auth_repository_impl.dart';
import 'feat/auth/domain/repository/auth_repository.dart';
import 'feat/auth/presentation/bloc/auth_bloc.dart';
import 'feat/auth/domain/usecases/register_user.dart';
import 'feat/auth/domain/repository/user_repository.dart';
import 'feat/auth/data/repository/user_repository_impl.dart';

// ================= SETTINGS =================
import 'feat/setting/domain/repository/settings_repository.dart';
import 'feat/setting/data/datasource/setting_remote_data_source.dart';
import 'feat/setting/data/datasource/settings_local_data_source.dart';
import 'feat/setting/data/repository/setting_repository_impl.dart';
import 'feat/setting/presentation/bloc/settings_bloc.dart';
import 'feat/setting/presentation/bloc/settings_event.dart';

// ================= GUARDIANS =================
import 'feat/guardians/domain/repository/guardian_repository.dart';
import 'feat/guardians/data/repository/guardian_repository_impl.dart';
import 'feat/guardians/data/data_source/guardian_remote_data_source.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Background service
  await initializeService();

  // 🔥 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // ================= SETTINGS DATA =================
  final settingsRemoteDataSource = SettingsRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

  final settingsLocalDataSource = SettingsLocalDataSourceImpl(
    sharedPreferences: prefs,
  );

  final settingsRepository = SettingsRepositoryImpl(
    remoteDataSource: settingsRemoteDataSource,
    localDataSource: settingsLocalDataSource,
  );

  // ================= GUARDIANS DATA =================
  final guardianRemoteDataSource =
  GuardianRemoteDataSource(FirebaseFirestore.instance);
  final guardianRepository =
  GuardianRepositoryImpl(guardianRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuth.instance),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(FirebaseFirestore.instance),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (_) => settingsRepository,
        ),
        RepositoryProvider<GuardianRepository>(
          create: (_) => guardianRepository,
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
        // ================= AUTH BLOC =================
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
            registerUser: RegisterUser(
              context.read<AuthRepository>(),
              context.read<UserRepository>(),
            ),
          ),
        ),

        // ================= SETTINGS BLOC =================
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            context.read<SettingsRepository>(),
          )..add(LoadHiddenPanicSettingsEvent()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'SafeTrek',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        builder: (context, child) {
          return PanicListener(
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
