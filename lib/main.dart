import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safetrek_project/feat/home/presentation/splash/splash_screen.dart';
import 'firebase_options.dart'; // File này được tạo ra sau khi bạn chạy flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeTrek',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
