import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
import 'package:volume_controller/volume_controller.dart';

class EmergencyData {
  final String time;
  // final String location;
  final String battery;
  // final String mapsLink;

  EmergencyData({
    required this.time,
    // required this.location,
    required this.battery,
    // required this.mapsLink,
  });
}

class EmergencyUtils {
  static Future<EmergencyData> triggerEmergency(BuildContext context) async {
    double batteryLevel = await VolumeController().getVolume();
    String batteryString = "${(batteryLevel * 100).toInt()}% (giả lập từ volume)";
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm:ss dd/MM/yyyy').format(now);
    return EmergencyData(
      time: timeString,
      battery: batteryString,
    );
  }

  static Future<void> sendTripAlert(BuildContext context,
      {required String triggerMethod}) async {
    try {
      debugPrint('sendTripAlert: 시작 (reason=$triggerMethod)');
      final now = DateTime.now();
      final timeString = DateFormat('HH:mm:ss dd/MM/yyyy').format(now);

      // Prefer the most recent alertLog location as the source of truth.
      GeoPoint? alertGeo;
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final q = await FirebaseFirestore.instance
              .collection('alertLogs')
              .where('userId', isEqualTo: currentUser.uid)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            final data = q.docs.first.data();
            final loc = data['location'];
            if (loc is GeoPoint) {
              alertGeo = loc;
            } else if (loc is Map) {
              final lat = loc['latitude'];
              final lng = loc['longitude'];
              if (lat != null && lng != null) {
                alertGeo = GeoPoint(lat as double, lng as double);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to read alertLogs: $e');
      }

      Map<String, dynamic>? location;
      if (alertGeo != null) {
        location = {'latitude': alertGeo.latitude, 'longitude': alertGeo.longitude};
      } else {
        try {
          location = await LocationService.getCurrentLocation();
        } catch (_) {
          location = null;
        }
      }

      final mapsLink = (location != null)
          ? 'https://www.google.com/maps/search/?api=1&query=${location['latitude']},${location['longitude']}'
          : 'Không xác định';
      double batteryLevel = await VolumeController().getVolume();
      String batteryString = "${(batteryLevel * 100).toInt()}%";
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserName =
          currentUser?.displayName ?? currentUser?.email ?? 'Người dùng SafeTrek';
      String subject;
      String message;
      if (triggerMethod == 'PanicButton') {
        subject = 'Cảnh báo KHẨN CẤP — $currentUserName';
        message =
            'CẢNH BÁO KHẨN CẤP! $currentUserName vừa kích hoạt nút khẩn cấp lúc $timeString.'
            '\nVị trí hiện tại: $mapsLink.'
            '\nMức pin điện thoại: $batteryString.'
            '\nVui lòng liên hệ và kiểm tra ngay lập tức.';
      } else if (triggerMethod == 'DuressPIN') {
        subject = 'Cảnh báo ép buộc — $currentUserName';
        message =
            'Cảnh báo ép buộc: $currentUserName đã nhập mã ép buộc lúc $timeString.'
            '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
            '\nMức pin điện thoại: $batteryString.'
            '\nCảnh báo đã được gửi một cách bí mật.';
      } else {
        subject = 'Cảnh báo chuyến đi — $currentUserName';
        message =
            'Cảnh báo! $currentUserName đã bắt đầu một chuyến đi lúc $timeString và không checkin an toàn.'
            '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
            '\nMức pin điện thoại còn lại: $batteryString.';
      }

      final guardianRepo = context.read<GuardianRepository>();
      final guardians = await guardianRepo.getGuardians();
      debugPrint('sendTripAlert: guardians found = ${guardians.length}');

      if (guardians.isEmpty) {
        debugPrint('sendTripAlert: no guardians to notify');
        return;
      }

      const String serviceId = 'service_u067o0m';
      const String templateId = 'template_8vaabhk';
      const String userId = '7y1TkwAcQ2x9zi7XT';

      for (var guardian in guardians) {
        final email = guardian.email;
        final name = guardian.name;
        debugPrint('sendTripAlert: preparing to send to $name <$email>');
        if (email != null && email.isNotEmpty) {
          final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
          try {
            final response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'service_id': serviceId,
                'template_id': templateId,
                'user_id': userId,
                'template_params': {
                  'to_email': email,
                  'to_name': name,
                  'from_name': currentUserName,
                  'from_email': currentUser?.email ?? 'no-reply@yourdomain.com',
                  'subject': subject,
                  'message': message,
                  'reason': triggerMethod,
                },
              }),
            );
            debugPrint('sendTripAlert: EmailJS => ${response.statusCode}');
            debugPrint('sendTripAlert: body => ${response.body}');
          } catch (e) {
            debugPrint('sendTripAlert: HTTP post failed for $email: $e');
          }
        } else {
          debugPrint('sendTripAlert: guardian $name has no email, skipping');
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi gửi email cảnh báo: $e');
    }
  }

  /// Version that accepts a GuardianRepository directly to avoid using
  /// `BuildContext` after widget unmounts. Use this from async flows
  /// where the State might be disposed while awaits run.
  static Future<void> sendTripAlertWithRepo(
      GuardianRepository guardianRepo,
      {required String triggerMethod}) async {
    try {
      debugPrint('sendTripAlertWithRepo: start (reason=$triggerMethod)');
      final now = DateTime.now();
      final timeString = DateFormat('HH:mm:ss dd/MM/yyyy').format(now);

      // Prefer the latest alertLog entry for location, fallback to LocationService
      GeoPoint? alertGeo;
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final q = await FirebaseFirestore.instance
              .collection('alertLogs')
              .where('userId', isEqualTo: currentUser.uid)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) {
            final data = q.docs.first.data();
            final loc = data['location'];
            if (loc is GeoPoint) {
              alertGeo = loc;
            } else if (loc is Map) {
              final lat = loc['latitude'];
              final lng = loc['longitude'];
              if (lat != null && lng != null) {
                alertGeo = GeoPoint(lat as double, lng as double);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to read alertLogs: $e');
      }

      Map<String, dynamic>? location;
      if (alertGeo != null) {
        location = {'latitude': alertGeo.latitude, 'longitude': alertGeo.longitude};
      } else {
        try {
          location = await LocationService.getCurrentLocation();
        } catch (_) {
          location = null;
        }
      }

      final mapsLink = (location != null)
          ? 'https://www.google.com/maps/search/?api=1&query=${location['latitude']},${location['longitude']}'
          : 'Không xác định';

      double batteryLevel = await VolumeController().getVolume();
      String batteryString = "${(batteryLevel * 100).toInt()}%";

      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserName =
          currentUser?.displayName ?? currentUser?.email ?? 'Người dùng SafeTrek';

      // Build subject and message based on trigger reason
      String subject;
      String message;
      if (triggerMethod == 'PanicButton') {
        subject = 'Cảnh báo KHẨN CẤP — $currentUserName';
        message =
            'CẢNH BÁO KHẨN CẤP! $currentUserName vừa kích hoạt nút khẩn cấp lúc $timeString.'
            '\nVị trí hiện tại: $mapsLink.'
            '\nMức pin điện thoại: $batteryString.'
            '\nVui lòng liên hệ và kiểm tra ngay lập tức.';
      } else if (triggerMethod == 'DuressPIN') {
        subject = 'Cảnh báo ép buộc — $currentUserName';
        message =
            'Cảnh báo ép buộc: $currentUserName đã nhập mã ép buộc lúc $timeString.'
            '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
            '\nMức pin điện thoại: $batteryString.'
            '\nCảnh báo đã được gửi một cách bí mật.';
      } else {
        subject = 'Cảnh báo chuyến đi — $currentUserName';
        message =
            'Cảnh báo! $currentUserName đã bắt đầu một chuyến đi lúc $timeString và không checkin an toàn.'
            '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
            '\nMức pin điện thoại còn lại: $batteryString.';
      }

      final guardians = await guardianRepo.getGuardians();
      debugPrint('sendTripAlertWithRepo: guardians found = ${guardians.length}');
      if (guardians.isEmpty) return;

      const String serviceId = 'service_u067o0m';
      const String templateId = 'template_8vaabhk';
      const String userId = '7y1TkwAcQ2x9zi7XT';

      for (var guardian in guardians) {
        final email = guardian.email;
        final name = guardian.name;
        debugPrint('sendTripAlertWithRepo: sending to $name <$email>');
        if (email != null && email.isNotEmpty) {
          final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
          try {
            final response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'service_id': serviceId,
                'template_id': templateId,
                'user_id': userId,
                'template_params': {
                  'to_email': email,
                  'to_name': name,
                  'from_name': currentUserName,
                  'from_email': currentUser?.email ?? 'no-reply@yourdomain.com',
                  'subject': subject,
                  'message': message,
                  'reason': triggerMethod,
                },
              }),
            );
            debugPrint('sendTripAlertWithRepo: EmailJS => ${response.statusCode}');
            debugPrint('sendTripAlertWithRepo: body => ${response.body}');
          } catch (e) {
            debugPrint('sendTripAlertWithRepo: HTTP post failed for $email: $e');
          }
        } else {
          debugPrint('sendTripAlertWithRepo: guardian $name has no email, skipping');
        }
      }
    } catch (e) {
      debugPrint('sendTripAlertWithRepo: error: $e');
    }
  }
}
