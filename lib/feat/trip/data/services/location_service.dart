import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
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

      final settings = LocationSettings(accuracy: LocationAccuracy.best);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 10));

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
      // For background tasks prefer lower accuracy to save battery
      final settings = LocationSettings(accuracy: LocationAccuracy.low);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 10));

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('Lỗi lấy vị trí (Background): $e');
      return null;
    }
  }

  // Provide a position stream with configurable accuracy/distanceFilter
  static Stream<Map<String, dynamic>> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.low,
    int distanceFilter = 10,
  }) {
    final settings = LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
    return Geolocator.getPositionStream(locationSettings: settings).map((pos) {
      return {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };
    });
  }
}
