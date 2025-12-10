import 'package:flutter/material.dart';
import 'package:safetrek_project/screens/trip/start_trip.dart';
import 'package:safetrek_project/widgets/app_bar.dart';
import 'package:safetrek_project/widgets/bottom_navigation.dart';
import 'package:safetrek_project/widgets/emergency_button.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, 0.30),
            end: Alignment(1.00, 0.70),
            colors: [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildActionCard(
                icon: Icons.location_on,
                iconColor: Colors.pinkAccent,
                iconBgColor: Colors.pink.shade50,
                title: "Bắt đầu Chuyến đi Mới",
                subtitle: "Theo dõi hành trình an toàn",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StartTrip()),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.history,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
                title: "Lịch sử Chuyến đi",
                subtitle: "0 chuyến đi",
                onTap: () {},
              ),
              const SizedBox(height: 40),
              const EmergencyButton(),
              const SizedBox(height: 15),
              const Text(
                'Nhấn nút này để gửi cảnh báo khẩn cấp ngay lập tức đến tất cả người bảo vệ của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Hướng dẫn sử dụng",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF004085)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildBulletPoint("Bắt đầu chuyến đi mới khi đi ra ngoài"),
                    _buildBulletPoint("Xem lại lịch sử các chuyến đi"),
                    _buildBulletPoint("Nhấn nút khẩn cấp khi gặp nguy hiểm"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(color: Color(0xFF004085), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF004085), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
