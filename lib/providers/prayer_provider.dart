import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times.dart';
import '../core/services/prayer_time_service.dart';
import '../core/services/notification_service.dart';
import 'achievement_provider.dart';

/// Prayer Provider
/// Manages prayer times state and updates
class PrayerProvider extends ChangeNotifier {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final NotificationService _notificationService = NotificationService();

  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String? _error;
  CalculationMethod _calculationMethod = CalculationMethod.egyptianGeneralAuthority;
  String? _locationName;
  Timer? _updateTimer;
  bool _refreshing = false;

  // Getters
  PrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CalculationMethod get calculationMethod => _calculationMethod;
  String? get locationName => _locationName;

  PrayerProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 400), _initialize);
    });
  }

  /// Initialize prayer provider
  Future<void> _initialize() async {
    await _notificationService.initialize();
    await loadSavedMethod();
    await refreshPrayerTimes();
    _startAutoUpdate();
  }

  /// Load saved calculation method
  Future<void> loadSavedMethod() async {
    try {
      _calculationMethod = await _prayerTimeService.getSavedCalculationMethod();
      notifyListeners();
    } catch (e) {
      print('Error loading saved method: $e');
    }
  }

  /// Refresh prayer times
  Future<void> refreshPrayerTimes() async {
    if (_refreshing) return;
    _refreshing = true;
    final showSpinner = _prayerTimes == null;
    if (showSpinner) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final pair = await _prayerTimeService.getTodayAndTomorrow();
      _prayerTimes = pair.today;
      _error = null;

      try {
        await _notificationService.reschedulePrayerNotifications(
          today: pair.today,
          tomorrow: pair.tomorrow,
        );
      } catch (_) {}
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('disabled')) {
        _error = 'location_disabled';
      } else if (message.contains('denied')) {
        _error = 'location_denied';
      } else if (message.contains('timeout')) {
        _error = 'location_timeout';
      } else {
        _error = 'prayer_load_failed';
      }
      print('Error refreshing prayer times: $e');
    } finally {
      _refreshing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request permissions explicitly
  Future<void> requestPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
    await refreshPrayerTimes();
  }

  /// Change calculation method
  Future<void> changeCalculationMethod(CalculationMethod method) async {
    _calculationMethod = method;
    await _prayerTimeService.saveCalculationMethod(method);
    await refreshPrayerTimes();
  }

  /// Start auto-update timer (updates every minute)
  void _startAutoUpdate() {
    // Update prayer times every minute to keep countdown accurate
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      notifyListeners(); // Notify to update countdown
      
      // Check if we need to refresh prayer times (new day)
      final now = DateTime.now();
      if (_prayerTimes != null) {
        final prayerDate = _prayerTimes!.date;
        if (!_isSameDay(now, prayerDate)) {
          refreshPrayerTimes();
        }
      }
    });
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get time until next prayer (for countdown)
  Duration? getTimeUntilNextPrayer() {
    return _prayerTimes?.getTimeUntilNextPrayer();
  }

  /// Get next prayer info
  Map<String, dynamic>? getNextPrayer() {
    return _prayerTimes?.getNextPrayer();
  }

  /// Test notification
  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  // Track completed prayers locally for the session/day
  final Set<String> _completedPrayers = {};
  
  // Method to mark prayer as complete
  void markPrayerComplete(String prayerName, AchievementProvider achievementProvider) {
    _completedPrayers.add(prayerName);
    notifyListeners();

    // Check for "5 Prayers" achievement
    if (_completedPrayers.length >= 5) { // Assuming Fajr, Dhuhr, Asr, Maghrib, Isha
       achievementProvider.unlockAchievement('spiritual_5prayers');
    }
    
    // Check for Fajr Warrior (simple version checking if today's Fajr is done)
    if (prayerName == 'Fajr' || prayerName == 'الفجر') {
       // Logic for streak would be more complex, but for now we can trigger a daily check
    }
  }

  bool isPrayerCompleted(String prayerName) {
    return _completedPrayers.contains(prayerName);
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
