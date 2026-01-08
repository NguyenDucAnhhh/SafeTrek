import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[background_service] onStart called');
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // ignore if already initialized or running in an env without options
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();

  Timer? periodicTimer;

  Future<void> pollOnce() async {
    try {
      debugPrint('[background_service] pollOnce start');
      String? tripId = prefs.getString('current_trip_id');
      int? startTime = prefs.getInt('trip_start_time');
      int? duration = prefs.getInt('trip_duration'); // duration in seconds
      debugPrint('[background_service] tripId=$tripId startTime=$startTime duration=$duration');

      if (tripId == null || startTime == null || duration == null) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'SafeTrek (idle)',
            content: 'No active trip',
          );
        }
        return;
      }

      int now = DateTime.now().millisecondsSinceEpoch;
      int elapsed = ((now - startTime) / 1000).round();
      await prefs.setInt('trip_elapsed', elapsed);

      if (elapsed >= duration) {
        debugPrint('[background_service] trip $tripId timed out (elapsed=$elapsed >= duration=$duration)');
          // Trip timed out -> treat as alarmed (no PIN confirmation)
          await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
            'elapsed': elapsed,
            'status': 'Báo động',
            'actualEndTime': FieldValue.serverTimestamp(),
          });

          // Create an alert log so history shows an alarm event
          try {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            await FirebaseFirestore.instance.collection('alertLogs').add({
              'tripId': tripId,
              'userId': userId,
              'triggerMethod': 'Timeout',
              'timestamp': FieldValue.serverTimestamp(),
              'location': null,
              'status': 'Sent',
              'alertType': 'Auto',
            });
          } catch (e) {
            debugPrint('[background_service] failed to create alertLog: $e');
          }

          // clear local trip info
          await prefs.remove('current_trip_id');
          await prefs.remove('trip_start_time');
          await prefs.remove('trip_duration');

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'SafeTrek đã kết thúc',
              content: 'Chuyến đi đã hết giờ',
            );
          }

          debugPrint('[background_service] clearing local prefs for trip $tripId');
          // Stop timer until a new trip is started
          periodicTimer?.cancel();
          periodicTimer = null;
          return;
      }

      // Update elapsed and status
      debugPrint('[background_service] updating trip $tripId elapsed=$elapsed status=Đang tiến hành');
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'elapsed': elapsed,
        'status': 'Đang tiến hành',
      });

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'SafeTrek đang chạy nền',
          content: 'Đã đếm: $elapsed giây',
        );
      }
    } catch (e, st) {
      debugPrint('[background_service] pollOnce error: $e');
      debugPrint('$st');
      // Log or handle errors; do not crash the timer
    }
  }

  // Run immediately once
  await pollOnce();

  // Ensure only one periodic timer runs
  if (periodicTimer == null) {
    periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await pollOnce();
    });
  }
}

Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  return true;
}
