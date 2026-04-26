import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_progress.dart';
import '../models/level_system.dart';
import '../data/xp_rewards.dart';
import '../data/motivational_messages.dart';

/// Gamification Provider
/// Manages user progress, XP, levels, streak, and recovery points
class GamificationProvider extends ChangeNotifier {
  UserProgress _userProgress = const UserProgress();
  String _currentMotivation = '';

  UserProgress get userProgress => _userProgress;
  String get currentMotivation => _currentMotivation;

  // Convenience getters
  int get currentStreak => _userProgress.currentStreak;
  int get totalXP => _userProgress.totalXP;
  int get currentLevel => _userProgress.currentLevel;
  int get recoveryPoints => _userProgress.recoveryPoints;
  int get totalCleanDays => _userProgress.totalCleanDays;

  /// Get current level info
  Level getCurrentLevelInfo() {
    return LevelDefinitions.getLevelFromXP(_userProgress.totalXP);
  }

  /// Get XP needed for next level
  int? getXPToNextLevel() {
    final currentLevelInfo = getCurrentLevelInfo();
    return currentLevelInfo.getXPToNextLevel(_userProgress.totalXP);
  }

  /// Get progress percentage to next level (0-100)
  double getProgressToNextLevel() {
    final currentLevelInfo = getCurrentLevelInfo();
    return currentLevelInfo.getProgressToNextLevel(_userProgress.totalXP);
  }

  GamificationProvider() {
    _loadProgress();
  }

  /// Load user progress from storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('user_progress');

      if (progressJson != null) {
        final json = jsonDecode(progressJson) as Map<String, dynamic>;
        _userProgress = UserProgress.fromJson(json);
      }

      _updateMotivation();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    }
  }

  /// Save user progress to storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = jsonEncode(_userProgress.toJson());
      await prefs.setString('user_progress', progressJson);
    } catch (e) {
      debugPrint('Error saving user progress: $e');
    }
  }

  /// Complete a clean day
  Future<Map<String, dynamic>> completeCleanDay({
    bool allPrayersCompleted = false,
  }) async {
    final oldXP = _userProgress.totalXP;
    final newStreak = _userProgress.currentStreak + 1;

    // Calculate XP reward
    final xpEarned = XPRewards.calculateCleanDayXP(
      streak: newStreak,
      allPrayersCompleted: allPrayersCompleted,
    );

    // Calculate recovery points
    final recoveryPointsEarned = XPRewards.recoveryPointsPerDay;

    // Update progress
    _userProgress = _userProgress.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > _userProgress.longestStreak
          ? newStreak
          : _userProgress.longestStreak,
      totalCleanDays: _userProgress.totalCleanDays + 1,
      totalXP: _userProgress.totalXP + xpEarned,
      recoveryPoints: _userProgress.recoveryPoints + recoveryPointsEarned,
      lastCheckIn: DateTime.now(),
      streakStartDate:
          _userProgress.streakStartDate ?? DateTime.now(),
    );

    // Update level
    _updateLevel(oldXP);

    // Update brain recovery stats
    _updateBrainRecovery();

    // Update motivation
    _updateMotivation(isSuccess: true);

    await _saveProgress();
    notifyListeners();

    // Return results for UI feedback
    return {
      'xpEarned': xpEarned,
      'recoveryPointsEarned': recoveryPointsEarned,
      'newStreak': newStreak,
      'leveledUp': LevelDefinitions.isLevelUp(oldXP, _userProgress.totalXP),
      'newLevel': LevelDefinitions.getLevelFromXP(_userProgress.totalXP).level,
    };
  }

  /// Add XP from any action
  Future<Map<String, dynamic>> addXP(int xp, {String reason = ''}) async {
    final oldXP = _userProgress.totalXP;

    _userProgress = _userProgress.copyWith(
      totalXP: _userProgress.totalXP + xp,
    );

    _updateLevel(oldXP);
    await _saveProgress();
    notifyListeners();

    return {
      'xpEarned': xp,
      'leveledUp': LevelDefinitions.isLevelUp(oldXP, _userProgress.totalXP),
      'newLevel': LevelDefinitions.getLevelFromXP(_userProgress.totalXP).level,
    };
  }

  /// Add recovery points
  Future<void> addRecoveryPoints(int points) async {
    _userProgress = _userProgress.copyWith(
      recoveryPoints: _userProgress.recoveryPoints + points,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// Spend recovery points (for unlocking rewards)
  Future<bool> spendRecoveryPoints(int points) async {
    if (_userProgress.recoveryPoints < points) {
      return false;
    }

    _userProgress = _userProgress.copyWith(
      recoveryPoints: _userProgress.recoveryPoints - points,
    );

    await _saveProgress();
    notifyListeners();
    return true;
  }

  /// Handle relapse - resets streak, level, and decreases brain recovery
  /// Encourages user to start fresh and rebuild
  Future<void> handleRelapse() async {
    // Reset streak
    _userProgress = _userProgress.copyWith(
      currentStreak: 0,
      streakStartDate: null,
    );

    // Reset level back to 1 (beginning)
    _userProgress = _userProgress.copyWith(
      currentLevel: 1,
      totalXP: 0, // Reset XP to start from beginning
    );

    // Decrease brain recovery stats significantly (go back 50%)
    _userProgress = _userProgress.copyWith(
      dopamineBalance: (_userProgress.dopamineBalance * 0.5).clamp(0.0, 100.0),
      focusImprovement: (_userProgress.focusImprovement * 0.5).clamp(0.0, 100.0),
      energyLevel: (_userProgress.energyLevel * 0.5).clamp(0.0, 100.0),
      moodStability: (_userProgress.moodStability * 0.5).clamp(0.0, 100.0),
    );

    _updateMotivation(isSuccess: false);
    await _saveProgress();
    notifyListeners();

    debugPrint('Relapse handled. Level reset to 1, brain recovery decreased.');
  }

  /// Fast comeback after relapse
  Future<void> fastComeback() async {
    final xpBonus = XPRewards.fastComeback;

    _userProgress = _userProgress.copyWith(
      currentStreak: 1,
      streakStartDate: DateTime.now(),
      totalXP: _userProgress.totalXP + xpBonus,
    );

    await _saveProgress();
    notifyListeners();
  }

  /// Update user level based on XP
  void _updateLevel(int oldXP) {
    final newLevel = LevelDefinitions.getLevelFromXP(_userProgress.totalXP);

    if (newLevel.level != _userProgress.currentLevel) {
      _userProgress = _userProgress.copyWith(
        currentLevel: newLevel.level,
      );

      // Award recovery points for level up
      final levelupPoints = XPRewards.getRecoveryPointsForLevel(newLevel.level);
      _userProgress = _userProgress.copyWith(
        recoveryPoints: _userProgress.recoveryPoints + levelupPoints,
      );

      debugPrint('Level up! New level: ${newLevel.titleArabic}');
    }
  }

  /// Update brain recovery statistics based on clean days
  /// More accurate calculation based on neuroscience research
  void _updateBrainRecovery() {
    final days = _userProgress.totalCleanDays;

    // Dopamine balance: Significant recovery in 90 days, with faster gains early
    // Uses logarithmic curve for realistic brain healing
    final dopamine = days >= 90 
        ? 100.0 
        : (100 * (1 - (1 / (1 + days / 15)))).clamp(0.0, 100.0);

    // Focus: Noticeable improvement in 60 days
    final focus = days >= 60 
        ? 100.0 
        : (100 * (1 - (1 / (1 + days / 12)))).clamp(0.0, 100.0);

    // Energy: Quick recovery in 30 days
    final energy = days >= 30 
        ? 100.0 
        : (100 * (1 - (1 / (1 + days / 8)))).clamp(0.0, 100.0);

    // Mood: Fastest recovery in 21 days
    final mood = days >= 21 
        ? 100.0 
        : (100 * (1 - (1 / (1 + days / 5)))).clamp(0.0, 100.0);

    _userProgress = _userProgress.copyWith(
      dopamineBalance: dopamine,
      focusImprovement: focus,
      energyLevel: energy,
      moodStability: mood,
    );
  }

  /// Update motivational message
  void _updateMotivation({bool? isSuccess}) {
    if (isSuccess != null && !isSuccess) {
      _currentMotivation = MotivationalMessages.getMessage(
        context: MessageContext.relapse,
        streak: _userProgress.currentStreak,
      );
    } else if (_userProgress.currentStreak > 0 &&
        XPRewards.getStreakMilestoneBonus(_userProgress.currentStreak) > 0) {
      _currentMotivation = MotivationalMessages.getMessage(
        context: MessageContext.milestone,
        streak: _userProgress.currentStreak,
      );
    } else {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        _currentMotivation = MotivationalMessages.getMessage(
          context: MessageContext.morning,
          streak: _userProgress.currentStreak,
        );
      } else if (hour >= 18) {
        _currentMotivation = MotivationalMessages.getMessage(
          context: MessageContext.evening,
          streak: _userProgress.currentStreak,
        );
      } else {
        _currentMotivation = MotivationalMessages.getMessage(
          context: MessageContext.general,
          streak: _userProgress.currentStreak,
        );
      }
    }
  }

  /// Start a new journey
  Future<void> startJourney(String journeyId) async {
    _userProgress = _userProgress.copyWith(
      activeJourneyId: journeyId,
      journeyStartDate: DateTime.now(),
      currentStreak: 0,
      streakStartDate: DateTime.now(),
    );

    await _saveProgress();
    notifyListeners();
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    _userProgress = const UserProgress();
    _currentMotivation = '';

    await _saveProgress();
    notifyListeners();
  }
}
