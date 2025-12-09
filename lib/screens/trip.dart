import 'package:flutter/material.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 60,
          flexibleSpace: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0.5, 0),
                    end: Alignment(0.5, 1),
                    colors: [const Color(0xFF1E90FF), const Color(0xFF0066CC)]
                )
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8), // Khoảng cách nhỏ giữa Icon và Text
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'SafeTrek',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600, // Tăng độ đậm chút cho đẹp
                      height: 1.25,
                    ),
                  ),
                  Text(
                    'Giữ bạn an toàn trên mọi hành trình',
                    style: TextStyle(
                      color: Color(0xFFDAEAFE),
                      fontSize: 11,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        body: Container(

            height: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, 0.30),
                end: Alignment(1.00, 0.70),
                colors: [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionCard(
                  icon: Icons.location_on,
                  iconColor: Colors.pinkAccent,
                  iconBgColor: Colors.pink.shade50,
                  title: "Bắt đầu Chuyến đi Mới",
                  subtitle: "Theo dõi hành trình an toàn",
                  onTap: () {},
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
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE60000), // Màu đỏ tươi
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.warning_amber_rounded, size: 60, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "NÚT KHẨN CẤP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Bấm để gửi cảnh báo ngay lập tức",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Nhấn nút này để gửi cảnh báo khẩn cấp ngay lập tức đến tất cả người bảo vệ của bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey,fontSize: 13
                  ),
                )
              ],
            )
        )
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
}
