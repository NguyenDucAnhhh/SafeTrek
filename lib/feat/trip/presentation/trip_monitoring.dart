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
  final String tripId;

  const TripMonitoring({
    super.key,
    required this.durationInMinutes,
    required this.tripId,
  });

  @override
  State<TripMonitoring> createState() => _TripMonitoringState();
}

class _TripMonitoringState extends State<TripMonitoring> {
  late Timer _countdownTimer;
  late Timer _locationTimer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = Duration(minutes: widget.durationInMinutes);
    _startCountdownTimer();
    _startLocationTracking();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        _triggerAlert('Timeout');
      } else if (mounted) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _recordLocation();
    });
  }

  Future<void> _recordLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location == null) return;

      await FirebaseFirestore.instance.collection('locationHistories').add({
        'tripId': widget.tripId,
        'latitude': location['latitude'],
        'longitude': location['longitude'],
        'timestamp': FieldValue.serverTimestamp(),
        'batteryLevel': null,
      });
    } catch (e) {
      debugPrint("Error recording location: $e");
    }
  }

  Future<void> _triggerAlert(String triggerMethod) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final location = await LocationService.getCurrentLocation();

      await FirebaseFirestore.instance.collection('alertLogs').add({
        'tripId': widget.tripId,
        'userId': user.uid,
        'triggerMethod': triggerMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'location': location != null ? GeoPoint(location['latitude'], location['longitude']) : null,
        'status': 'Sent',
        'alertType': 'Push',
      });

      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
        'status': 'Alarmed',
        'actualEndTime': FieldValue.serverTimestamp(),
        'lastLocation': location != null ? GeoPoint(location['latitude'], location['longitude']) : null,
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
      debugPrint("Error triggering alert: $e");
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _locationTimer.cancel();
    super.dispose();
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
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return const PinInputDialog();
      },
    );

    if (enteredPin == null || !mounted) return;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final safePIN = userDoc.data()?['safePIN'] as String?;
      final duressPIN = userDoc.data()?['duressPIN'] as String?;

      String? tripStatus;
      String messageText = '';
      Color messageColor = Colors.green;
      bool isDuress = false;

      if (enteredPin == safePIN) {
        tripStatus = 'CompletedSafe';
        messageText = 'Đã xác nhận đến nơi an toàn!';
      } else if (enteredPin == duressPIN) {
        tripStatus = 'Alarmed';
        messageText = 'Cảnh báo ép buộc đã được gửi đi một cách bí mật.';
        messageColor = Colors.orange;
        isDuress = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã PIN không chính xác'), backgroundColor: Colors.red),
        );
        return;
      }
      
      _countdownTimer.cancel();
      _locationTimer.cancel();

      if (isDuress) {
        await _triggerAlert('DuressPIN');
      } else {
        final lastLocation = await LocationService.getCurrentLocation();
        await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
          'status': tripStatus,
          'lastLocation': lastLocation != null ? GeoPoint(lastLocation['latitude'], lastLocation['longitude']) : null,
          'actualEndTime': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageText), backgroundColor: messageColor),
      );
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
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
              EmergencyButton(
                onPressed: () => _triggerAlert('PanicButton'),
              ),
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
              onPressed: _showPinDialog,
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
