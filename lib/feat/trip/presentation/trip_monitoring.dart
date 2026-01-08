import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safetrek_project/core/widgets/app_bar.dart';
import 'package:safetrek_project/core/widgets/emergency_button.dart';
import 'package:safetrek_project/core/widgets/pin_input_dialog.dart';
import 'package:safetrek_project/feat/home/presentation/main_screen.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:safetrek_project/feat/trip/data/repository/trip_repository_impl.dart';
import 'package:safetrek_project/feat/trip/data/data_source/trip_remote_data_source.dart';
import 'package:safetrek_project/core/utils/emergency_utils.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:safetrek_project/feat/trip/presentation/trip.dart' as trip_page;

import '../../guardians/domain/repository/guardian_repository.dart';

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
  Timer? _locationTimer;
  late Duration _remainingTime;
  StreamSubscription<String?>? _tripStatusSubscription;
  late final TripRepositoryImpl _tripRepository;
  StreamSubscription<Map<String, dynamic>>? _positionSubscription;
  int? _prefsStartTimeMs;
  int? _prefsDurationSec;
  final List<Map<String, dynamic>> _locationBuffer = [];
  Timer? _flushTimer;
  String? _prefsTripId;
  String? _lastStatusHandled;
  bool _isNotifying = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = Duration(minutes: widget.durationInMinutes);
    _initFromPrefsAndStart();
    _tripRepository = TripRepositoryImpl(TripRemoteDataSource(FirebaseFirestore.instance));
    _startLocationTracking();
    _listenToTripStatus();
  }

  Future<void> _initFromPrefsAndStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final startTime = prefs.getInt('trip_start_time');
      final duration = prefs.getInt('trip_duration');
      final tripIdPref = prefs.getString('current_trip_id');
      _prefsTripId = tripIdPref ?? widget.tripId;

      // Cache prefs to avoid reading them every tick
      _prefsStartTimeMs = startTime;
      _prefsDurationSec = duration;

      if (_prefsStartTimeMs != null && _prefsDurationSec != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = ((now - _prefsStartTimeMs!) / 1000).round();
        final remainingSec = _prefsDurationSec! - elapsed;
        setState(() {
          _remainingTime = Duration(seconds: remainingSec > 0 ? remainingSec : 0);
        });
      }

      _startCountdownTimer();
    } catch (e) {
      _startCountdownTimer();
    }
  }

  void _listenToTripStatus() {
    _tripStatusSubscription = _tripRepository.subscribeToTripStatus(widget.tripId).listen((status) {
      if (status == null) return;
      if (_lastStatusHandled != null && _lastStatusHandled == status) return;
      _lastStatusHandled = status;

      try {
        _tripStatusSubscription?.cancel();
      } catch (_) {}

      if (_isNotifying) return;
      _isNotifying = true;

      if (status == 'Báo động') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chuyến đi đã báo động!'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      } else if (status == 'Kết thúc an toàn') {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xác nhận đến nơi an toàn!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        // Use cached prefs values to avoid repeated IO
        final startTime = _prefsStartTimeMs;
        final duration = _prefsDurationSec;
        if (startTime == null || duration == null) {
          if (mounted) setState(() => _remainingTime = Duration.zero);
          timer.cancel();
          return;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = ((now - startTime) / 1000).round();
        final remainingSec = duration - elapsed;
        if (remainingSec <= 0) {
          if (mounted) setState(() => _remainingTime = Duration.zero);
          timer.cancel();
          // Trigger alert flow (marks trip as Alarmed) when timer reaches zero
          await _triggerAlert('Timeout');
          return;
        }
        if (mounted) setState(() => _remainingTime = Duration(seconds: remainingSec));
      } catch (e) {
        debugPrint('Countdown error: $e');
      }
    });
  }

  void _startLocationTracking() {
    // Prefer position stream to avoid repeated heavy getCurrentPosition calls
    try {
      _positionSubscription = LocationService.getPositionStream().listen((location) async {
        // Convert location map into a stored record
        final record = {
          'tripId': widget.tripId,
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'timestamp': FieldValue.serverTimestamp(),
          'batteryLevel': null,
        };
        await _addToBuffer(record);
      });
    } catch (e) {
      debugPrint('Failed to start position stream, falling back to timer: $e');
      _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _recordLocation();
      });
    }
  }

  Future<void> _recordLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location == null) return;

      final record = {
        'tripId': widget.tripId,
        'latitude': location['latitude'],
        'longitude': location['longitude'],
        'timestamp': FieldValue.serverTimestamp(),
        'batteryLevel': null,
      };
      await _addToBuffer(record);
    } catch (e) {
      debugPrint("Error recording location: $e");
    }
  }

  Future<void> _addToBuffer(Map<String, dynamic> record) async {
    _locationBuffer.add(record);
    // Flush when buffer is large enough
    if (_locationBuffer.length >= 3) {
      await _flushLocationBuffer();
      return;
    }
    // Ensure periodic flush runs
    _startFlushTimer();
  }

  void _startFlushTimer() {
    _flushTimer ??= Timer.periodic(const Duration(seconds: 60), (_) async {
      await _flushLocationBuffer();
    });
  }

  Future<void> _flushLocationBuffer() async {
    if (_locationBuffer.isEmpty) return;
    try {
      await _tripRepository.addLocationBatch(List<Map<String, dynamic>>.from(_locationBuffer));
      _locationBuffer.clear();
    } catch (e) {
      debugPrint('Failed to flush location buffer: $e');
    }
  }

  Future<void> _triggerAlert(String triggerMethod) async {
    try {
      // Capture GuardianRepository early to avoid using BuildContext inside
      // async work (State may be unmounted by the time async ops complete).
      final guardianRepo = context.read<GuardianRepository>();
      // Stop UI timers immediately to avoid further countdown actions
      try {
        _countdownTimer.cancel();
      } catch (_) {}
      try {
        _locationTimer?.cancel();
      } catch (_) {}
      try {
        _positionSubscription?.cancel();
      } catch (_) {}
      try {
        _flushTimer?.cancel();
      } catch (_) {}
      await _flushLocationBuffer();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final location = await LocationService.getCurrentLocation();
      final alert = {
        'tripId': widget.tripId,
        'userId': user.uid,
        'triggerMethod': triggerMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'location': location != null ? GeoPoint(location['latitude'], location['longitude']) : null,
        'status': 'Sent',
        'alertType': 'Push',
      };

      await _tripRepository.addAlertLog(alert);

      await _tripRepository.updateTrip(widget.tripId, {
        'status': 'Báo động',
        'actualEndTime': FieldValue.serverTimestamp(),
        'lastLocation': location != null ? GeoPoint(location['latitude'], location['longitude']) : null,
      });

      // Try to send SMS via Cloud Function to guardians
      try {
        final func = FirebaseFunctions.instance.httpsCallable('sendAlertSms');
        await func.call(<String, dynamic>{'tripId': widget.tripId, 'reason': triggerMethod});
      } catch (e) {
        debugPrint('sendAlertSms failed: $e');
      }

      // Also send email alerts to guardians (uses EmergencyUtils -> EmailJS)
      try {
        await EmergencyUtils.sendTripAlertWithRepo(guardianRepo, triggerMethod: triggerMethod);
      } catch (e) {
        debugPrint('sendTripAlertWithRepo failed: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ĐÃ GỬI CẢNH BÁO KHẨN CẤP!'),
            backgroundColor: Colors.red,
          ),
        );
        // After sending a panic alert via the on-screen emergency button,
        // return the user to the Trip screen so they leave monitoring view.
        if (triggerMethod == 'PanicButton') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const trip_page.Trip()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint("Error triggering alert: $e");
    }
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _locationTimer?.cancel();
    _tripStatusSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
    return false;
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

      String tripStatus;
      String messageText;
      Color messageColor;

      if (enteredPin == safePIN) {
        tripStatus = 'Kết thúc an toàn';
        messageText = 'Đã xác nhận đến nơi an toàn!';
        messageColor = Colors.green;

        // Hủy timer ngay
        _countdownTimer.cancel();
        _locationTimer?.cancel();

        // CẬP NHẬT NGAY LẬP TỨC
        final lastLocation = await LocationService.getCurrentLocation();
        await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).update({
          'status': tripStatus,
          'lastLocation': lastLocation != null ? GeoPoint(lastLocation['latitude'], lastLocation['longitude']) : null,
          'actualEndTime': FieldValue.serverTimestamp(),
        });

      } else if (enteredPin == duressPIN) {
        tripStatus = 'Báo động';
        messageText = 'Cảnh báo ép buộc đã được gửi đi một cách bí mật.';
        messageColor = Colors.orange;

        // Hủy timer ngay
        _countdownTimer.cancel();
        _locationTimer?.cancel();

        // CẬP NHẬT NGAY LẬP TỨC (hàm _triggerAlert sẽ làm việc này)
        await _triggerAlert('DuressPIN');

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã PIN không chính xác'), backgroundColor: Colors.red),
        );
        return;
      }

      // Hiển thị thông báo và điều hướng
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
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!mounted) return;
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      },
      child: Scaffold(
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
      )
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
