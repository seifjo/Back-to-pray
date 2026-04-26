import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/urge_event.dart';
import '../data/xp_rewards.dart';
import '../data/dhikr_content.dart';

/// Urge Resistance Provider
/// Manages urge timer, tracking, and rewards
class UrgeResistanceProvider extends ChangeNotifier {
  // Timer state
  bool _isTimerActive = false;
  int _secondsRemaining = 90;
  Timer? _timer;

  // Statistics
  UrgeResistanceStats _stats = const UrgeResistanceStats();

  // Current session
  DateTime? _urgeStartTime;

  // Getters
  bool get isTimerActive => _isTimerActive;
  int get secondsRemaining => _secondsRemaining;
  UrgeResistanceStats get stats => _stats;
  int get totalUrges => _stats.totalUrges;
  int get successfulResistances => _stats.successfulResistances;
  double get successRate => _stats.successRate;

  /// Callbacks for external coordination
  Function(int xp)? onUrgeResistSuccess;
  Function()? onUrgeResistFail;

  UrgeResistanceProvider() {
    _loadStats();
  }

  /// Load statistics from storage
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final totalUrges = prefs.getInt('urge_total') ?? 0;
      final successful = prefs.getInt('urge_successful') ?? 0;
      final failed = prefs.getInt('urge_failed') ?? 0;
      final consecutive = prefs.getInt('urge_consecutive') ?? 0;
      final totalXP = prefs.getInt('urge_total_xp') ?? 0;

      // Load recent events
      final eventsJson = prefs.getStringList('urge_events') ?? [];
      final events = eventsJson
          .map((e) => UrgeEvent.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();

      _stats = UrgeResistanceStats(
        totalUrges: totalUrges,
        successfulResistances: successful,
        failedResistances: failed,
        consecutiveSuccesses: consecutive,
        totalXPEarned: totalXP,
        recentEvents: events,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading urge stats: $e');
    }
  }

  /// Save statistics to storage
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('urge_total', _stats.totalUrges);
      await prefs.setInt('urge_successful', _stats.successfulResistances);
      await prefs.setInt('urge_failed', _stats.failedResistances);
      await prefs.setInt('urge_consecutive', _stats.consecutiveSuccesses);
      await prefs.setInt('urge_total_xp', _stats.totalXPEarned);

      // Save recent events (keep last 50)
      final recentEvents = _stats.recentEvents.take(50).toList();
      final eventsJson = recentEvents
          .map((e) => jsonEncode(e.toJson()))
          .toList();
      await prefs.setStringList('urge_events', eventsJson);
    } catch (e) {
      debugPrint('Error saving urge stats: $e');
    }
  }

  /// Start the 90-second urge resistance timer
  void startUrgeTimer() {
    if (_isTimerActive) return;

    _isTimerActive = true;
    _secondsRemaining = 90;
    _urgeStartTime = DateTime.now();

    notifyListeners();

    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;

      if (_secondsRemaining <= 0) {
        _handleTimerComplete(success: true);
      }

      notifyListeners();
    });
  }

  /// Cancel the timer (user chose to stop)
  void cancelTimer({bool failed = true}) {
    if (!_isTimerActive) return;

    _timer?.cancel();
    _timer = null;
    _isTimerActive = false;

    if (failed) {
      _handleTimerComplete(success: false);
    } else {
      // Just cancel without recording
      _secondsRemaining = 90;
      _urgeStartTime = null;
      notifyListeners();
    }
  }

  /// Handle timer completion
  Future<void> _handleTimerComplete({required bool success}) async {
    _timer?.cancel();
    _timer = null;
    _isTimerActive = false;

    final duration = success ? 90 : (90 - _secondsRemaining);

    // Calculate XP and Unlock Achievements (only if successful)
    int xpEarned = 0;
    if (success && _urgeStartTime != null) {
      xpEarned = XPRewards.calculateUrgeResistanceXP(
        streak: 0, 
        urgeTime: _urgeStartTime!,
      );

      // --- Unlock Achievements ---
      if (onUrgeResistSuccess != null) {
        // We use a callback or direct provider access if possible.
        // Since providers can't easily depend on each other cyclically, 
        // we'll rely on the UI or main GamificationProvider to listen to this event.
        // BUT, for now let's assume valid access or implementing internal checking.
        
        // Actually best way: The provider already has stats.
        // We need an external service to actually "unlock" the achievement in the AchievementProvider.
        // For simplicity in this architecture, we will fire the callback and let the listener handle it,
        // OR we inject AchievementProvider. 
        // Let's assume the callbacks mechanism is used by GamificationProvider to unlock things.
      }
    }

    // Create event
    final event = UrgeEvent(
      timestamp: _urgeStartTime ?? DateTime.now(),
      success: success,
      durationSeconds: duration,
      xpEarned: xpEarned,
    );

    // Update stats
    _stats = _stats.copyWith(
      totalUrges: _stats.totalUrges + 1,
      successfulResistances:
          success ? _stats.successfulResistances + 1 : _stats.successfulResistances,
      failedResistances:
          !success ? _stats.failedResistances + 1 : _stats.failedResistances,
      consecutiveSuccesses:
          success ? _stats.consecutiveSuccesses + 1 : 0,
      totalXPEarned: _stats.totalXPEarned + xpEarned,
      recentEvents: [event, ..._stats.recentEvents],
    );

    await _saveStats();

    // Trigger callbacks
    if (success && onUrgeResistSuccess != null) {
      onUrgeResistSuccess!(xpEarned);
    } else if (!success && onUrgeResistFail != null) {
      onUrgeResistFail!();
    }

    _secondsRemaining = 90;
    _urgeStartTime = null;

    notifyListeners();
  }

  /// Get dhikr content for current timer state
  String getCurrentDhikrContent() {
    return DhikrContent.getTimerContent(_secondsRemaining);
  }

  /// Get breathing guidance
  String getBreathingGuidance() {
    final guidance = DhikrContent.getBreathingGuidance();
    final index = (90 - _secondsRemaining) ~/ 20;
    return guidance[index % guidance.length];
  }

  /// Get urges from last N days
  List<UrgeEvent> getEventsFromLastDays(int days) {
    return _stats.getEventsFromLastDays(days);
  }

  /// Get today's urge count
  int getTodayUrgeCount() {
    final today = DateTime.now();
    return _stats.recentEvents.where((e) {
      return e.timestamp.year == today.year &&
          e.timestamp.month == today.month &&
          e.timestamp.day == today.day;
    }).length;
  }

  /// Reset statistics (for testing)
  Future<void> resetStats() async {
    _stats = const UrgeResistanceStats();
    await _saveStats();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
