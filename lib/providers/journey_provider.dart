import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/active_journey.dart';
import '../models/journey.dart';
import '../data/journey_content.dart';
import './gamification_provider.dart';

/// Journey Provider
/// Manages active journey tracking and progress
class JourneyProvider extends ChangeNotifier {
  ActiveJourney? _activeJourney;
  GamificationProvider? _gamificationProvider;

  ActiveJourney? get activeJourney => _activeJourney;
  bool get hasActiveJourney => _activeJourney != null;
  String? get activeJourneyId => _activeJourney?.journeyId;

  /// Inject gamification provider for coordination
  void setGamificationProvider(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  JourneyProvider() {
    _loadActiveJourney();
  }

  /// Load active journey from storage
  Future<void> _loadActiveJourney() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final journeyJson = prefs.getString('active_journey');

      if (journeyJson != null) {
        final json = jsonDecode(journeyJson) as Map<String, dynamic>;
        _activeJourney = ActiveJourney.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading active journey: $e');
    }
  }

  /// Save active journey to storage
  Future<void> _saveActiveJourney() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_activeJourney != null) {
        final journeyJson = jsonEncode(_activeJourney!.toJson());
        await prefs.setString('active_journey', journeyJson);
      } else {
        await prefs.remove('active_journey');
      }
    } catch (e) {
      debugPrint('Error saving active journey: $e');
    }
  }

  /// Start a new journey
  Future<void> startJourney(String journeyId) async {
    _activeJourney = ActiveJourney(
      journeyId: journeyId,
      startDate: DateTime.now(),
      currentStreak: 0,
      totalDays: 0,
      status: JourneyStatus.active,
    );

    // Also update gamification provider
    await _gamificationProvider?.startJourney(journeyId);

    await _saveActiveJourney();
    notifyListeners();
  }

  /// Log daily commitment (clean day)
  Future<Map<String, dynamic>> logDailyCommitment() async {
    if (_activeJourney == null) {
      throw StateError('No active journey');
    }

    // Check if already logged today
    if (_activeJourney!.isTodayLogged()) {
      return {'alreadyLogged': true};
    }

    // Create check-in record
    final checkIn = JourneyCheckIn(
      date: DateTime.now(),
      wasSuccessful: true,
    );

    // Update journey
    _activeJourney = _activeJourney!.copyWith(
      currentStreak: _activeJourney!.currentStreak + 1,
      totalDays: _activeJourney!.totalDays + 1,
      lastCheckIn: DateTime.now(),
      checkIns: [..._activeJourney!.checkIns, checkIn],
    );

    // Coordinate with gamification provider
    final result = await _gamificationProvider?.completeCleanDay() ?? {};

    await _saveActiveJourney();
    notifyListeners();

    return {
      'success': true,
      'newStreak': _activeJourney!.currentStreak,
      'totalDays': _activeJourney!.totalDays,
      ...result,
    };
  }

  /// Log relapse (compassionate handling)
  Future<void> logRelapse({String? note}) async {
    if (_activeJourney == null) {
      throw StateError('No active journey');
    }

    // Create check-in record
    final checkIn = JourneyCheckIn(
      date: DateTime.now(),
      wasSuccessful: false,
      note: note,
    );

    // Reset streak but keep total days
    _activeJourney = _activeJourney!.copyWith(
      currentStreak: 0,
      lastCheckIn: DateTime.now(),
      checkIns: [..._activeJourney!.checkIns, checkIn],
    );

    // Coordinate with gamification provider
    await _gamificationProvider?.handleRelapse();

    await _saveActiveJourney();
    notifyListeners();
  }

  /// Get current journey definition
  Journey? getCurrentJourney() {
    if (_activeJourney == null) return null;

    return JourneyContent.allJourneys.firstWhere(
      (j) => j.id == _activeJourney!.journeyId,
      orElse: () => JourneyContent.allJourneys.first,
    );
  }

  /// Get current stage based on total days
  JourneyStage? getCurrentStage() {
    final journey = getCurrentJourney();
    if (journey == null || _activeJourney == null) return null;

    int daysSoFar = 0;
    for (final stage in journey.stages) {
      daysSoFar += stage.durationDays;
      if (_activeJourney!.totalDays < daysSoFar) {
        return stage;
      }
    }

    // If completed all stages, return last one
    return journey.stages.isNotEmpty ? journey.stages.last : null;
  }

  /// Get current stage index (0-based)
  int getCurrentStageIndex() {
    final journey = getCurrentJourney();
    if (journey == null || _activeJourney == null) return 0;

    int daysSoFar = 0;
    for (int i = 0; i < journey.stages.length; i++) {
      daysSoFar += journey.stages[i].durationDays;
      if (_activeJourney!.totalDays < daysSoFar) {
        return i;
      }
    }

    return journey.stages.length - 1;
  }

  /// Calculate recovery progress (0-100%)
  double getRecoveryProgress() {
    final journey = getCurrentJourney();
    if (journey == null || _activeJourney == null) return 0.0;

    final totalDays = journey.recommendedDays;
    final progress = (_activeJourney!.totalDays / totalDays * 100).clamp(0.0, 100.0);
    return progress;
  }

  /// Get days in current stage
  int getDaysInCurrentStage() {
    final journey = getCurrentJourney();
    if (journey == null || _activeJourney == null) return 0;

    int stageStartDay = 0;

    for (int i = 0; i < getCurrentStageIndex(); i++) {
      stageStartDay += journey.stages[i].durationDays;
    }

    return _activeJourney!.totalDays - stageStartDay;
  }

  /// Pause journey
  Future<void> pauseJourney() async {
    if (_activeJourney == null) return;

    _activeJourney = _activeJourney!.copyWith(
      status: JourneyStatus.paused,
    );

    await _saveActiveJourney();
    notifyListeners();
  }

  /// Resume journey
  Future<void> resumeJourney() async {
    if (_activeJourney == null) return;

    _activeJourney = _activeJourney!.copyWith(
      status: JourneyStatus.active,
    );

    await _saveActiveJourney();
    notifyListeners();
  }

  /// Complete journey
  Future<void> completeJourney() async {
    if (_activeJourney == null) return;

    _activeJourney = _activeJourney!.copyWith(
      status: JourneyStatus.completed,
    );

    await _saveActiveJourney();
    notifyListeners();
  }

  /// Start the same journey again from day one.
  Future<void> restartJourney() async {
    if (_activeJourney == null) return;
    _activeJourney = ActiveJourney(
      journeyId: _activeJourney!.journeyId,
      startDate: DateTime.now(),
      status: JourneyStatus.active,
    );
    await _saveActiveJourney();
    notifyListeners();
  }

  /// Reset journey (for testing or user request)
  Future<void> resetJourney() async {
    _activeJourney = null;
    await _saveActiveJourney();
    notifyListeners();
  }

  /// Get success rate
  double getSuccessRate() {
    if (_activeJourney == null || _activeJourney!.checkIns.isEmpty) {
      return 0.0;
    }

    final successful = _activeJourney!.checkIns
        .where((c) => c.wasSuccessful)
        .length;
    
    return (successful / _activeJourney!.checkIns.length * 100);
  }
}
