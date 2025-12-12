import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safetrek_project/screens/placeholder_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PlaceholderScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1877F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'SafeTrek',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Giữ bạn an toàn trên mọi hành trình',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
