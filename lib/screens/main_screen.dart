import 'package:flutter/material.dart';
import 'package:safetrek_project/screens/guardians/guardians.dart';
import 'package:safetrek_project/screens/setting/setting.dart';
import 'package:safetrek_project/screens/trip/trip.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang con tương ứng với các tab
  static const List<Widget> _widgetOptions = <Widget>[
    Trip(),
    GuardiansScreen(),
    Setting(),
  ];

  // Hàm này sẽ được gọi khi một tab được nhấn
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng AppBar đã được tách riêng
      appBar: const CustomAppBar(),

      // Hiển thị trang con tương ứng với tab được chọn
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      // Sử dụng BottomNavigation đã được tách riêng
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
