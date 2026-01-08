import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
  /// Thực hiện quy trình khẩn cấp: Lấy dữ liệu và Gửi email
  static Future<EmergencyData> triggerEmergency(BuildContext context) async {
    // 1. Lấy thông tin vị trí
    // final locationData = await LocationService.getCurrentLocation();
    // String locationString = "Không xác định";
    // String mapsLink = "";
    // if (locationData != null) {
    //   locationString = "${locationData['latitude']}, ${locationData['longitude']}";
    //   mapsLink = "https://www.google.com/maps/search/?api=1&query=${locationData['latitude']},${locationData['longitude']}";
    // }

    // 2. Lấy thông tin pin (hiện tại giả lập từ volume)
    double batteryLevel = await VolumeController().getVolume();
    String batteryString = "${(batteryLevel * 100).toInt()}% (giả lập từ volume)";

    // 3. Lấy thời gian hiện tại
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm:ss dd/MM/yyyy').format(now);

    // 4. (Legacy) Không tự động gửi email ở đây nữa — dùng sendTripAlert khi cần.
    // Giữ chức năng triggerEmergency để trả về dữ liệu hiển thị overlay.

    return EmergencyData(
      time: timeString,
      // location: locationString,
      battery: batteryString,
      // mapsLink: mapsLink,
    );
  }

  /// Gửi email cảnh báo đến tất cả guardian của người dùng (dùng EmailJS)
  /// Nội dung tuân theo yêu cầu của dự án.
  static Future<void> sendTripAlert(BuildContext context,
      {required String triggerMethod}) async {
    try {
      debugPrint('sendTripAlert: 시작 (reason=$triggerMethod)');
      final now = DateTime.now();
      final timeString = DateFormat('HH:mm:ss dd/MM/yyyy').format(now);

      // Lấy vị trí (UI-safe)
      Map<String, dynamic>? location;
      try {
        location = await LocationService.getCurrentLocation();
      } catch (_) {
        location = null;
      }

      final mapsLink = (location != null)
          ? 'https://www.google.com/maps/search/?api=1&query=${location['latitude']},${location['longitude']}'
          : 'Không xác định';

      // Lấy mức pin (hiện tại giả lập)
      double batteryLevel = await VolumeController().getVolume();
      String batteryString = "${(batteryLevel * 100).toInt()}%";

      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserName =
          currentUser?.displayName ?? currentUser?.email ?? 'Người dùng SafeTrek';

      final message =
          'Cảnh báo! $currentUserName đã bắt đầu một chuyến đi lúc $timeString và không checkin an toàn.'
          '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
          '\nMức pin điện thoại còn lại: $batteryString.';

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
                  'subject': 'Cảnh báo chuyến đi — $currentUserName',
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

      Map<String, dynamic>? location;
      try {
        location = await LocationService.getCurrentLocation();
      } catch (_) {
        location = null;
      }

      final mapsLink = (location != null)
          ? 'https://www.google.com/maps/search/?api=1&query=${location['latitude']},${location['longitude']}'
          : 'Không xác định';

      double batteryLevel = await VolumeController().getVolume();
      String batteryString = "${(batteryLevel * 100).toInt()}%";

      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserName =
          currentUser?.displayName ?? currentUser?.email ?? 'Người dùng SafeTrek';

      final message =
          'Cảnh báo! $currentUserName đã bắt đầu một chuyến đi lúc $timeString và không checkin an toàn.'
          '\nVị trí cuối cùng được ghi nhận: $mapsLink.'
          '\nMức pin điện thoại còn lại: $batteryString.';

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
                  'subject': 'Cảnh báo chuyến đi — $currentUserName',
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
