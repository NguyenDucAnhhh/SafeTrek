import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/core/widgets/emergency_button.dart';
import 'package:safetrek_project/core/widgets/pin_input_dialog.dart';
import 'package:safetrek_project/feat/home/presentation/main_screen.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';

class TripMonitoring extends StatefulWidget {
  final int durationInMinutes;

  const TripMonitoring({super.key, required this.durationInMinutes});

  @override
  State<TripMonitoring> createState() => _TripMonitoringState();
}

class _TripMonitoringState extends State<TripMonitoring> {
  int _selectedIndex = 0;
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = Duration(minutes: widget.durationInMinutes);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds == 0) {
        timer.cancel();
        // TODO: Handle auto-sending alert when timer finishes
      } else {
        if (mounted) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showPinDialog() async {
    final enteredPin = await showDialog<String>(
      context: context,
      barrierDismissible: false, // User must enter PIN
      builder: (BuildContext context) {
        return const PinInputDialog();
      },
    );

    if (enteredPin != null && mounted) {
      // Validate PIN against Firestore
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Người dùng chưa đăng nhập'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        final safePIN = userDoc.data()?['safePIN'] as String?;
        final duressPIN = userDoc.data()?['duressPIN'] as String?;
        String? tripStatus;
        String messageText = '';
        Color messageColor = Colors.red;

        if (enteredPin == safePIN) {
          // Safe PIN - mark as safe
          tripStatus = 'Đã đến nơi an toàn';
          messageText = 'Đã xác nhận đến nơi an toàn!';
          messageColor = Colors.green;
        } else if (enteredPin == duressPIN) {
          // Duress PIN - mark as danger but still end trip
          tripStatus = 'Nguy hiểm';
          messageText = 'Đã xác nhận đến nơi an toàn!';
          messageColor = Colors.green;
        } else {
          // PIN incorrect
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã PIN không chính xác'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Update trip status in Firestore
        // Get the most recent active trip without needing complex index
        final tripsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where('userId', isEqualTo: uid)
            .where('status', isEqualTo: 'Đang tiến hành')
            .get();

        if (tripsSnapshot.docs.isNotEmpty) {
          // Sort by startedAt locally and get the most recent
          final sortedDocs = tripsSnapshot.docs.toList();
          sortedDocs.sort((a, b) {
            final dateA = (a.data()['startedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            final dateB = (b.data()['startedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
            return dateB.compareTo(dateA); // descending order
          });

          final tripId = sortedDocs.first.id;
          
          // Lấy vị trí cuối cùng trước khi cập nhật
          final lastLocation = await LocationService.getCurrentLocation();
          
          await FirebaseFirestore.instance
              .collection('trips')
              .doc(tripId)
              .update({
                'status': tripStatus,
                'lastLocation': lastLocation,
              });
        }

        _timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(messageText),
            backgroundColor: messageColor,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false, // Remove all previous routes
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F4FF), Color(0xFFE2E9FF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTimerCard(),
              const SizedBox(height: 40),
              const EmergencyButton(),
              const SizedBox(height: 15),
              const Text(
                'Nhấn nút này để gửi cảnh báo khẩn cấp ngay lập tức đến tất cả người bảo vệ của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildTimerCard() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_remainingTime),
                    style: const TextStyle(
                      color: Color(0xFF8A76F3),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'còn lại',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.pink, size: 16),
                SizedBox(width: 8),
                Text(
                  'Hà Nội, Việt Nam', // This should be dynamic later
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showPinDialog, // Show PIN dialog on press
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Tôi đã An toàn - Check-in',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
