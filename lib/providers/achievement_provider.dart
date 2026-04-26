import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../data/achievement_definitions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  List<String> _unlockedAchievementIds = [];

  // Callbacks for UI notifications
  Function(Achievement)? onAchievementUnlocked;

  List<Achievement> get achievements => _achievements;

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  int get totalUnlocked => unlockedAchievements.length;
  int get totalAchievements => _achievements.length;

  AchievementProvider() {
    _loadAchievements();
  }

  /// Load achievements and unlock state
  Future<void> _loadAchievements() async {
    // Load all achievement definitions
    _achievements = AchievementDefinitions.getAllAchievements();

    // Load unlock state from storage
    final prefs = await SharedPreferences.getInstance();
    final unlockedJson = prefs.getStringList('unlocked_achievements') ?? [];
    _unlockedAchievementIds = unlockedJson;

    // Apply unlock state
    _achievements = _achievements.map((a) {
      final isUnlocked = _unlockedAchievementIds.contains(a.id);
      return a.copyWith(
        isUnlocked: isUnlocked,
        // You might want to load unlock dates too
      );
    }).toList();

    notifyListeners();
  }

  /// Save unlock state
  Future<void> _saveUnlockState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_achievements', _unlockedAchievementIds);
  }

  /// Check and unlock achievements based on user progress
  Future<List<Achievement>> checkAndUnlockAchievements({
    required int streak,
    required int totalCleanDays,
    int? urgesResisted,
    bool? allPrayersToday,
    bool? fajrPrayed,
    bool? quranRead,
    bool? fastComeback,
  }) async {
    final newlyUnlocked = <Achievement>[];

    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      // Check consistency achievements
      if (achievement.category == AchievementCategory.consistency) {
        shouldUnlock = _checkConsistencyAchievement(achievement.type, streak);
      }

      // Check urge resistance achievements
      if (achievement.category == AchievementCategory.urgeResistance &&
          urgesResisted != null) {
        shouldUnlock = _checkUrgeAchievement(achievement.type, urgesResisted);
      }

      // Check spiritual achievements
      if (achievement.category == AchievementCategory.spiritual) {
        shouldUnlock = _checkSpiritualAchievement(
          achievement.type,
          allPrayersToday: allPrayersToday,
          fajrPrayed: fajrPrayed,
          quranRead: quranRead,
        );
      }

      // Check comeback achievements
      if (achievement.category == AchievementCategory.comeback &&
          fastComeback == true) {
        shouldUnlock = achievement.type == AchievementType.comebackFast;
      }

      if (shouldUnlock) {
        await unlockAchievement(achievement.id);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  /// Unlock a specific achievement
  Future<void> unlockAchievement(String achievementId) async {
    if (_unlockedAchievementIds.contains(achievementId)) return;

    _unlockedAchievementIds.add(achievementId);

    // Update achievement object
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now(),
      );

      // Trigger callback for UI animation
      if (onAchievementUnlocked != null) {
        onAchievementUnlocked!(_achievements[index]);
      }
    }

    await _saveUnlockState();
    notifyListeners();
  }

  /// Check consistency achievements
  bool _checkConsistencyAchievement(AchievementType type, int streak) {
    switch (type) {
      case AchievementType.day1:
        return streak >= 1;
      case AchievementType.day3:
        return streak >= 3;
      case AchievementType.day7:
        return streak >= 7;
      case AchievementType.day14:
        return streak >= 14;
      case AchievementType.day21:
        return streak >= 21;
      case AchievementType.day30:
        return streak >= 30;
      case AchievementType.day60:
        return streak >= 60;
      case AchievementType.day90:
        return streak >= 90;
      case AchievementType.day180:
        return streak >= 180;
      case AchievementType.day365:
        return streak >= 365;
      default:
        return false;
    }
  }

  /// Check urge resistance achievements
  bool _checkUrgeAchievement(AchievementType type, int urgesResisted) {
    switch (type) {
      case AchievementType.urgeFirst:
        return urgesResisted >= 1;
      case AchievementType.urge5:
        return urgesResisted >= 5;
      case AchievementType.urge10:
        return urgesResisted >= 10;
      default:
        return false;
    }
  }

  /// Check spiritual achievements
  bool _checkSpiritualAchievement(
    AchievementType type, {
    bool? allPrayersToday,
    bool? fajrPrayed,
    bool? quranRead,
  }) {
    switch (type) {
      case AchievementType.prayerDay:
        return allPrayersToday == true;
      case AchievementType.fajrWarrior:
        return fajrPrayed == true; // Would need 7-day tracking
      case AchievementType.quranDaily:
        return quranRead == true; // Would need 7-day tracking
      default:
        return false;
    }
  }

  /// Get achievements by category
  List<Achievement> getByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Get achievements by rarity
  List<Achievement> getByRarity(AchievementRarity rarity) {
    return _achievements.where((a) => a.rarity == rarity).toList();
  }

  /// Get achievement statistics
  Map<String, int> getStatistics() {
    return {
      'total': _achievements.length,
      'unlocked': totalUnlocked,
      'common': unlockedAchievements
          .where((a) => a.rarity == AchievementRarity.common)
          .length,
      'rare': unlockedAchievements
          .where((a) => a.rarity == AchievementRarity.rare)
          .length,
      'epic': unlockedAchievements
          .where((a) => a.rarity == AchievementRarity.epic)
          .length,
      'legendary': unlockedAchievements
          .where((a) => a.rarity == AchievementRarity.legendary)
          .length,
    };
  }

  /// Reset all achievements (for testing)
  Future<void> resetAchievements() async {
    _unlockedAchievementIds.clear();
    _achievements = _achievements.map((a) {
      return a.copyWith(isUnlocked: false);
    }).toList();

    await _saveUnlockState();
    notifyListeners();
  }
}
