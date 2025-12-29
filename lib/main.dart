import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetrek_project/feat/home/presentation/splash/splash_screen.dart';
import 'package:safetrek_project/feat/setting/domain/repository/settings_repository.dart';

import 'feat/setting/data/datasource/setting_remote_data_source.dart';
import 'feat/setting/data/datasource/settings_local_data_source.dart';
import 'feat/setting/data/repository/setting_repository_impl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- DATA SOURCES ---
  final remoteDataSource = SettingsRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

  final localDataSource = SettingsLocalDataSourceImpl();

  // --- REPOSITORY ---
  final settingsRepository = SettingsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  runApp(
    RepositoryProvider<SettingsRepository>(
      create: (_) => settingsRepository,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeTrek',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const SplashScreen(),
    );
  }
}
