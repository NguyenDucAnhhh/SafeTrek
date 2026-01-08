import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';

// Guards to prevent duplicate service initialization and overlapping polls
bool _serviceStarted = false;
bool _isPolling = false;
Timer? _periodicTimer;

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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (_serviceStarted) {
    debugPrint('[background_service] onStart called but service already started');
    return;
  }
  _serviceStarted = true;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[background_service] onStart called');
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (_) {}

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[background_service] SharedPreferences unavailable: $e');
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'SafeTrek (error)',
          content: 'Prefs unavailable in background',
        );
      }
      return;
    }

    Future<void> pollOnce() async {
      if (_isPolling) return;
      _isPolling = true;
      try {
        debugPrint('[background_service] pollOnce start');
        String? tripId = prefs?.getString('current_trip_id');
        int? startTime = prefs?.getInt('trip_start_time');
        int? duration = prefs?.getInt('trip_duration');
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
        try {
          await prefs?.setInt('trip_elapsed', elapsed);
        } catch (e) {
          debugPrint('[background_service] failed to set trip_elapsed: $e');
        }

        if (elapsed >= duration) {
          debugPrint('[background_service] trip $tripId timed out (elapsed=$elapsed >= duration=$duration)');
          try {
            await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
              'elapsed': elapsed,
              'status': 'Báo động',
              'actualEndTime': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('[background_service] failed to update trip doc: $e');
          }

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

          try {
            await prefs?.remove('current_trip_id');
            await prefs?.remove('trip_start_time');
            await prefs?.remove('trip_duration');
          } catch (e) {
            debugPrint('[background_service] failed to clear prefs: $e');
          }

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'SafeTrek đã kết thúc',
              content: 'Chuyến đi đã hết giờ',
            );
          }

          debugPrint('[background_service] clearing local prefs for trip $tripId');
          _periodicTimer?.cancel();
          _periodicTimer = null;
          return;
        }

        debugPrint('[background_service] updating trip $tripId elapsed=$elapsed status=Đang tiến hành');
        try {
          final tripRef = FirebaseFirestore.instance.collection('trips').doc(tripId);
          final snap = await tripRef.get();
          final currentStatus = snap.data()?['status'] as String?;
          // Do not overwrite an active alarm or a safe-completed status
          if (currentStatus == 'Báo động' || currentStatus == 'Kết thúc an toàn') {
            // Update elapsed only, keep the terminal status
            await tripRef.update({'elapsed': elapsed});
            debugPrint('[background_service] preserved terminal status ($currentStatus) for trip $tripId');
          } else {
            await tripRef.update({
              'elapsed': elapsed,
              'status': 'Đang tiến hành',
            });
          }
        } catch (e) {
          debugPrint('[background_service] failed to update trip status: $e');
        }

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'SafeTrek đang chạy nền',
            content: 'Đã đếm: $elapsed giây',
          );
        }
      } catch (e, st) {
        debugPrint('[background_service] pollOnce error: $e');
        debugPrint('$st');
      } finally {
        _isPolling = false;
      }
    }

    await pollOnce();

    if (_periodicTimer == null) {
      _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
        try {
          await pollOnce();
        } catch (e, st) {
          debugPrint('[background_service] periodic poll error: $e');
          debugPrint('$st');
        }
      });
    }
  }, (error, stack) {
    debugPrint('[background_service] Uncaught error in zone: $error');
    debugPrint('$stack');
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  return true;
}
