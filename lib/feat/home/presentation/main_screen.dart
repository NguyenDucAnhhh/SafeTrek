import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../guardians/presentation/guardians.dart';
import '../../trip/presentation/trip.dart';
import 'setting/setting.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang con tương ứng với các tab
  final List<Widget> _widgetOptions = [
    const Trip(),
    const GuardiansScreen(),
    const Setting(),
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
