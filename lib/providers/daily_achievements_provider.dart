import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_achievement.dart';
import '../data/daily_achievements_data.dart';
import './gamification_provider.dart';

/// Daily Achievements Provider
/// Manages daily achievement tracking and streaks
class DailyAchievementsProvider extends ChangeNotifier {
  List<DailyAchievement> _achievements = [];
  DateTime? _lastResetDate;
  GamificationProvider? _gamificationProvider;

  List<DailyAchievement> get achievements => _achievements;
  
  /// Get achievements by category
  List<DailyAchievement> getByCategory(DailyAchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Get completion stats for today
  Map<String, int> getTodayStats() {
    final completed = _achievements.where((a) => a.isCompleted).length;
    final total = _achievements.length;
    final xpEarned = _achievements
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.xpReward);
    final pointsEarned = _achievements
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.pointsReward);

    return {
      'completed': completed,
      'total': total,
      'xpEarned': xpEarned,
      'pointsEarned': pointsEarned,
    };
  }

  /// Inject gamification provider
  void setGamificationProvider(GamificationProvider provider) {
    _gamificationProvider = provider;
  }

  DailyAchievementsProvider() {
    _loadAchievements();
  }

  /// Load achievements from storage
  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString('daily_achievements');
      final lastReset = prefs.getString('daily_achievements_last_reset');

      if (lastReset != null) {
        _lastResetDate = DateTime.parse(lastReset);
      }

      // Check if we need to reset for new day
      if (_shouldResetToday()) {
        await _resetDailyAchievements();
      } else if (achievementsJson != null) {
        final List<dynamic> jsonList = jsonDecode(achievementsJson);
        _achievements = jsonList
            .map((json) => DailyAchievement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Initialize from catalog
        _achievements = List.from(DailyAchievementsData.allDailyAchievements);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily achievements: $e');
      _achievements = List.from(DailyAchievementsData.allDailyAchievements);
    }
  }

  /// Save achievements to storage
  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _achievements.map((a) => a.toJson()).toList();
      await prefs.setString('daily_achievements', jsonEncode(jsonList));
      await prefs.setString(
        'daily_achievements_last_reset',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving daily achievements: $e');
    }
  }

  /// Check if should reset for new day
  bool _shouldResetToday() {
    if (_lastResetDate == null) return true;

    final now = DateTime.now();
    return now.year != _lastResetDate!.year ||
        now.month != _lastResetDate!.month ||
        now.day != _lastResetDate!.day;
  }

  /// Reset achievements for new day (preserve streaks)
  Future<void> _resetDailyAchievements() async {
    final newAchievements = <DailyAchievement>[];

    for (final achievement in DailyAchievementsData.allDailyAchievements) {
      // Find existing to carry over streak data
      final existing = _achievements.firstWhere(
        (a) => a.id == achievement.id,
        orElse: () => achievement,
      );

      // If was completed yesterday, increment streak
      // If not, reset streak to 0
      final wasCompletedYesterday = existing.isCompleted;
      final newStreak = wasCompletedYesterday ? existing.currentStreak : 0;
      final newBestStreak = existing.bestStreak;

      newAchievements.add(
        achievement.copyWith(
          isCompleted: false,
          completedDate: null,
          currentStreak: newStreak,
          bestStreak: newBestStreak,
        ),
      );
    }

    _achievements = newAchievements;
    _lastResetDate = DateTime.now();
    await _saveAchievements();
    notifyListeners();
  }

  /// Mark achievement as complete
  Future<Map<String, dynamic>> completeAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) {
      return {'success': false, 'error': 'Achievement not found'};
    }

    final achievement = _achievements[index];

    // Already completed
    if (achievement.isCompleted) {
      return {'success': false, 'error': 'Already completed today'};
    }

    // Update achievement
    final newStreak = achievement.currentStreak + 1;
    final newBestStreak = newStreak > achievement.bestStreak
        ? newStreak
        : achievement.bestStreak;

    _achievements[index] = achievement.copyWith(
      isCompleted: true,
      completedDate: DateTime.now(),
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );

    // Award XP and points through gamification provider
    if (_gamificationProvider != null) {
      await _gamificationProvider!.addXP(
        achievement.xpReward,
        reason: 'Daily: ${achievement.title}',
      );
      await _gamificationProvider!.addRecoveryPoints(achievement.pointsReward);
    }

    await _saveAchievements();
    notifyListeners();

    return {
      'success': true,
      'xpEarned': achievement.xpReward,
      'pointsEarned': achievement.pointsReward,
      'newStreak': newStreak,
      'isNewRecord': newStreak == newBestStreak && newStreak > 1,
    };
  }

  /// Undo completion (if user made mistake)
  Future<void> uncompleteAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    if (!achievement.isCompleted) return;

    _achievements[index] = achievement.copyWith(
      isCompleted: false,
      completedDate: null,
    );

    await _saveAchievements();
    notifyListeners();
  }

  /// Force check for daily reset (call on app start)
  Future<void> checkDailyReset() async {
    if (_shouldResetToday()) {
      await _resetDailyAchievements();
    }
  }

  /// Get category completion percentage
  double getCategoryProgress(DailyAchievementCategory category) {
    final categoryAchievements = _achievements
        .where((a) => a.category == category)
        .toList();
    
    if (categoryAchievements.isEmpty) return 0.0;

    final completed = categoryAchievements
        .where((a) => a.isCompleted)
        .length;

    return (completed / categoryAchievements.length * 100);
  }
}
