import 'package:geolocator/geolocator.dart';

class LocationService {
  // Lấy vị trí hiện tại của người dùng
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Kiểm tra permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null; // Permission denied
      }

      // Lấy vị trí hiện tại
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
      print('Lỗi lấy vị trí: $e');
      return null;
    }
  }
}
