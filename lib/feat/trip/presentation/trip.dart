import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:safetrek_project/feat/trip/presentation/start_trip.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_history.dart';
import 'package:safetrek_project/core/widgets/action_card.dart';
import 'package:safetrek_project/core/widgets/emergency_button.dart';
import 'package:safetrek_project/feat/trip/presentation/trip_monitoring.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  @override
  void initState() {
    super.initState();
    _checkAndResumeActiveTrip();
  }

  Future<void> _checkAndResumeActiveTrip() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final querySnapshot = await FirebaseFirestore.instance
      .collection('trips')
      .where('userId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'Đang tiến hành')
      .get();
    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.sort((a, b) {
        final aTs = (a.data()?['startedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTs = (b.data()?['startedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTs.compareTo(aTs);
      });
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final tripId = doc.id;
      final expectedEndTime = (data['expectedEndTime'] as Timestamp?)?.toDate();
      final now = DateTime.now();
      final remaining = expectedEndTime != null && expectedEndTime.isAfter(now)
          ? expectedEndTime.difference(now)
          : Duration.zero;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripMonitoring(
              durationInMinutes: remaining.inMinutes,
              tripId: tripId,
            ),
          ),
        );
      });
    }
  }
  bool _isSendingAlert = false;

  // Hàm xử lý cho nút khẩn cấp (đã được cập nhật)
  Future<void> _triggerInstantAlert() async {
    if (_isSendingAlert) return; // Ngăn chặn nhấn nhiều lần

    setState(() => _isSendingAlert = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Lấy vị trí hiện tại
      final location = await LocationService.getCurrentLocation();

      // Tạo bản ghi trong alertLogs với tripId là null
      await FirebaseFirestore.instance.collection('alertLogs').add({
        'tripId': null, // Thay đổi ở đây: tripId được đặt là null
        'userId': user.uid,
        'triggerMethod': 'PanicButton',
        'timestamp': FieldValue.serverTimestamp(),
        'location': location != null ? GeoPoint(location['latitude'], location['longitude']) : null,
        'status': 'Sent',
        'alertType': 'Push', // Mặc định
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ĐÃ GỬI CẢNH BÁO KHẨN CẤP!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi cảnh báo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingAlert = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.00, 0.30),
            end: Alignment(1.00, 0.70),
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ActionCard(
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
              ActionCard(
                icon: Icons.history,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
                title: "Lịch sử Chuyến đi",
                subtitle: "Xem tất cả chuyến đi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TripHistory()),
                  );
                },
              ),
              const SizedBox(height: 40),
              EmergencyButton(
                onPressed: _triggerInstantAlert, // Nối dây hàm mới
              ),
              const SizedBox(height: 15),
              if (_isSendingAlert)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
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
                    const Row(
                      children: [
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
