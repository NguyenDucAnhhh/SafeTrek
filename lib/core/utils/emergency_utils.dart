import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetrek_project/feat/guardians/domain/repository/guardian_repository.dart';
// import 'package:safetrek_project/feat/trip/data/services/location_service.dart';
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

    // 4. Lấy danh sách người bảo vệ & Gửi Email TỰ ĐỘNG qua EmailJS
    try {
      final guardianRepo = context.read<GuardianRepository>();
      final guardians = await guardianRepo.getGuardians();

      if (guardians.isNotEmpty) {
        // Cấu hình EmailJS
        const String serviceId = 'service_u067o0m';
        const String templateId = 'template_8vaabhk';
        const String userId = '7y1TkwAcQ2x9zi7XT';

        // Lấy thông tin người dùng hiện tại (nếu cần gửi kèm)
        final currentUser = FirebaseAuth.instance.currentUser;
        final currentUserName = currentUser?.displayName ?? currentUser?.email ?? 'Người dùng SafeTrek';

        for (var guardian in guardians) {
          if (guardian.email != null && guardian.email!.isNotEmpty) {
            
            final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
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
                  'to_email': guardian.email,
                  'to_name': guardian.name,
                  'from_name': currentUserName, // Thêm tên người gửi
                  'message': 'KHẨN CẤP!\n\n'
                      'Tôi ($currentUserName) đang gặp nguy hiểm và cần sự giúp đỡ ngay lập tức.\n\n'
                      'Thông tin chi tiết:\n'
                      '- Thời gian: $timeString\n'
                      // '- Vị trí: $locationString\n'
                      // '- Xem trên bản đồ: $mapsLink\n'
                      '- Mức pin thiết bị: $batteryString\n\n'
                      'Làm ơn hãy liên lạc hoặc đến vị trí của tôi ngay!',
                },
              }),
            );

            print('EmailJS Response: ${response.body}');
          }
        }
      }
    } catch (e) {
      print("Lỗi khi gửi cảnh báo: $e");
    }

    return EmergencyData(
      time: timeString,
      // location: locationString,
      battery: batteryString,
      // mapsLink: mapsLink,
    );
  }
}
