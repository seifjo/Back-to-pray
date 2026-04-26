import 'dart:math' show pi, cos, sin, atan2;
import 'package:geolocator/geolocator.dart';

/// Qibla Service
/// Calculates direction to Kaaba from user's location
class QiblaService {
  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction (bearing) from current location
  /// Returns bearing in degrees (0-360)
  Future<double> calculateQiblaDirection(double userLat, double userLon) async {
    // Convert to радианы
    final lat1 = _degreesToRadians(userLat);
    final lon1 = _degreesToRadians(userLon);
    final lat2 = _degreesToRadians(kaabaLatitude);
    final lon2 = _degreesToRadians(kaabaLongitude);

    // Calculate bearing using haversine formula
    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    
    var bearing = atan2(y, x);
    bearing = _radiansToDegrees(bearing);
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180.0;
  double _radiansToDegrees(double radians) => radians * 180.0 / pi;
}
