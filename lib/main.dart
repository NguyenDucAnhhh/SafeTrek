import 'package:flutter/material.dart';
import 'package:safetrek_project/screens/main_screen.dart';
import 'package:safetrek_project/screens/splash/splash_screen.dart';
import 'screens/guardians/guardians.dart';

void main(){
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTL',
      home: MainScreen(),
    );
  }
}