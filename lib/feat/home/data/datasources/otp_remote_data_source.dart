import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

abstract class OtpRemoteDataSource {
  Future<String> sendOtp(String email);
}

class OtpRemoteDataSourceImpl implements OtpRemoteDataSource {
  final http.Client client;

  // EmailJS Config - Bạn nên đưa chúng vào một file config riêng
  final String _serviceId = 'service_3wb3qkw';
  final String _templateId = 'template_rc6gjcc';
  final String _publicKey = '3BxtO5pqgnd6tCeFf';

  OtpRemoteDataSourceImpl({required this.client});

  String _generateOtp() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  @override
  Future<String> sendOtp(String email) async {
    final otp = _generateOtp();
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': email,
            'otp_code': otp,
          },
        }),
      );

      if (response.statusCode == 200) {
        return otp; // Trả về mã OTP nếu gửi thành công
      } else {
        // Ném một Exception cụ thể để BLoC có thể bắt và hiển thị lỗi
        throw Exception('Gửi OTP thất bại: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định khi gửi OTP: $e');
    }
  }
}
