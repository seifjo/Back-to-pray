import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/prayer_times.dart' as models;

/// Prayer Time Service
/// Handles calculation of prayer times using the adhan package
class PrayerTimeService {
  static const String _methodKey = 'calculation_method';
  static const String _latitudeKey = 'last_latitude';
  static const String _longitudeKey = 'last_longitude';

  /// Calculate prayer times for current location
  Future<models.PrayerTimes> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    models.CalculationMethod method = models.CalculationMethod.egyptianGeneralAuthority,
  }) async {
    try {
      final coordinates = Coordinates(latitude, longitude);
      final params = _getCalculationParameters(method);
      final date = DateComponents.from(DateTime.now());
      
      final prayerTimes = PrayerTimes(coordinates, date, params);

      return models.PrayerTimes(
        fajr: prayerTimes.fajr,
        sunrise: prayerTimes.sunrise,
        dhuhr: prayerTimes.dhuhr,
        asr: prayerTimes.asr,
        maghrib: prayerTimes.maghrib,
        isha: prayerTimes.isha,
        date: DateTime.now(),
      );
    } catch (e) {
      print('Error calculating prayer times: $e');
      rethrow;
    }
  }

  /// Get calculation parameters based on method
  CalculationParameters _getCalculationParameters(models.CalculationMethod method) {
    switch (method) {
      case models.CalculationMethod.egyptianGeneralAuthority:
        return CalculationMethod.egyptian.getParameters();
      case models.CalculationMethod.ummAlQura:
        return CalculationMethod.umm_al_qura.getParameters();
      case models.CalculationMethod.isna:
        return CalculationMethod.north_america.getParameters();
      case models.CalculationMethod.muslimWorldLeague:
        return CalculationMethod.muslim_world_league.getParameters();
      case models.CalculationMethod.karachi:
        return CalculationMethod.karachi.getParameters();
      case models.CalculationMethod.dubai:
        return CalculationMethod.dubai.getParameters();
      case models.CalculationMethod.kuwait:
        return CalculationMethod.kuwait.getParameters();
      case models.CalculationMethod.qatar:
        return CalculationMethod.qatar.getParameters();
      case models.CalculationMethod.singapore:
        return CalculationMethod.singapore.getParameters();
      case models.CalculationMethod.northAmerica:
        return CalculationMethod.north_america.getParameters();
      case models.CalculationMethod.other:
        return CalculationMethod.other.getParameters();
    }
  }

  /// Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please enable them in your phone settings.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please open your phone settings and allow location access for this app.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Save calculation method preference
  Future<void> saveCalculationMethod(models.CalculationMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_methodKey, method.index);
  }

  /// Get saved calculation method
  Future<models.CalculationMethod> getSavedCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_methodKey) ?? 0;
    return models.CalculationMethod.values[index];
  }

  /// Save last location
  Future<void> saveLastLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latitudeKey, latitude);
    await prefs.setDouble(_longitudeKey, longitude);
  }

  /// Get last saved location
  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latitudeKey);
    final lon = prefs.getDouble(_longitudeKey);

    if (lat != null && lon != null) {
      return {'latitude': lat, 'longitude': lon};
    }
    return null;
  }

  /// Get prayer times for today (with cached location)
  Future<models.PrayerTimes> getTodayPrayerTimes() async {
    try {
      // Try to get current location
      final position = await getCurrentLocation();
      await saveLastLocation(position.latitude, position.longitude);
      
      final method = await getSavedCalculationMethod();
      return await calculatePrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        method: method,
      );
    } catch (e) {
      // If location fails, try to use last saved location
      final lastLocation = await getLastLocation();
      if (lastLocation != null) {
        final method = await getSavedCalculationMethod();
        return await calculatePrayerTimes(
          latitude: lastLocation['latitude']!,
          longitude: lastLocation['longitude']!,
          method: method,
        );
      }
      rethrow;
    }
  }
}
