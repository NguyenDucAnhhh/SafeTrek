import 'package:geolocator/geolocator.dart';

class LocationService {
  // Hàm này dùng cho UI, có thể yêu cầu quyền
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Lỗi lấy vị trí (UI): $e');
      return null;
    }
  }

  // Hàm này dùng cho background, không bao giờ yêu cầu quyền
  static Future<Map<String, dynamic>?> getCurrentLocationForBackground() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('Lỗi lấy vị trí (Background): $e');
      return null;
    }
  }
}
