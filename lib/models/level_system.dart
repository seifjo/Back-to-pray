import 'package:flutter/material.dart';

/// Level in the recovery progression system
class Level {
  final int level;
  final String titleArabic;
  final int xpThreshold;
  final String badgeIcon;
  final Color badgeColor;
  final List<String> rewards;

  const Level({
    required this.level,
    required this.titleArabic,
    required this.xpThreshold,
    required this.badgeIcon,
    required this.badgeColor,
    this.rewards = const [],
  });

  /// Get XP needed for next level (null if max level)
  int? getXPToNextLevel(int currentXP) {
    final nextLevel = LevelDefinitions.getLevelByNumber(level + 1);
    if (nextLevel == null) return null;
    return nextLevel.xpThreshold - currentXP;
  }

  /// Get progress percentage to next level (0-100)
  double getProgressToNextLevel(int currentXP) {
    final nextLevel = LevelDefinitions.getLevelByNumber(level + 1);
    if (nextLevel == null) return 100.0;

    final currentLevelXP = xpThreshold;
    final nextLevelXP = nextLevel.xpThreshold;
    final progressInLevel = currentXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;

    return ((progressInLevel / xpNeededForLevel) * 100).clamp(0.0, 100.0);
  }
}

/// Static level definitions
class LevelDefinitions {
  static const List<Level> allLevels = [
    Level(
      level: 1,
      titleArabic: 'مبتدئ',
      xpThreshold: 0,
      badgeIcon: '🌱',
      badgeColor: Color(0xFF8BC34A),
      rewards: ['بداية رحلة التعافي'],
    ),
    Level(
      level: 2,
      titleArabic: 'مقاتل',
      xpThreshold: 100,
      badgeIcon: '⚔️',
      badgeColor: Color(0xFF03A9F4),
      rewards: ['فتح إنجازات جديدة', '+50 نقاط تعافي'],
    ),
    Level(
      level: 3,
      titleArabic: 'صامد',
      xpThreshold: 300,
      badgeIcon: '🛡️',
      badgeColor: Color(0xFF9C27B0),
      rewards: ['ثيمات جديدة', '+100 نقاط تعافي'],
    ),
    Level(
      level: 4,
      titleArabic: 'قوي',
      xpThreshold: 600,
      badgeIcon: '💪',
      badgeColor: Color(0xFFFF9800),
      rewards: ['شارات خاصة', '+150 نقاط تعافي'],
    ),
    Level(
      level: 5,
      titleArabic: 'متحكم',
      xpThreshold: 1200,
      badgeIcon: '🧘',
      badgeColor: Color(0xFFE91E63),
      rewards: ['أصوات تحفيزية', '+200 نقاط تعافي'],
    ),
    Level(
      level: 6,
      titleArabic: 'حر',
      xpThreshold: 2500,
      badgeIcon: '🦅',
      badgeColor: Color(0xFF00BCD4),
      rewards: ['اقتباسات حصرية', '+300 نقاط تعافي'],
    ),
    Level(
      level: 7,
      titleArabic: 'أسطورة',
      xpThreshold: 5000,
      badgeIcon: '👑',
      badgeColor: Color(0xFFFFD700),
      rewards: ['جميع المكافآت', 'شارة الأسطورة الذهبية'],
    ),
  ];

  /// Get level by level number
  static Level? getLevelByNumber(int levelNumber) {
    if (levelNumber < 1 || levelNumber > allLevels.length) return null;
    return allLevels[levelNumber - 1];
  }

  /// Get level from total XP
  static Level getLevelFromXP(int totalXP) {
    // Start from highest level and work down
    for (int i = allLevels.length - 1; i >= 0; i--) {
      if (totalXP >= allLevels[i].xpThreshold) {
        return allLevels[i];
      }
    }
    return allLevels[0]; // Default to level 1
  }

  /// Check if XP increase causes level up
  static bool isLevelUp(int oldXP, int newXP) {
    final oldLevel = getLevelFromXP(oldXP);
    final newLevel = getLevelFromXP(newXP);
    return newLevel.level > oldLevel.level;
  }

  /// Get the new level after XP increase
  static Level? getNewLevelIfLevelUp(int oldXP, int newXP) {
    if (isLevelUp(oldXP, newXP)) {
      return getLevelFromXP(newXP);
    }
    return null;
  }

  /// Get all levels user has unlocked
  static List<Level> getUnlockedLevels(int totalXP) {
    final currentLevel = getLevelFromXP(totalXP);
    return allLevels.where((l) => l.level <= currentLevel.level).toList();
  }

  /// Get all levels user hasn't unlocked yet
  static List<Level> getLockedLevels(int totalXP) {
    final currentLevel = getLevelFromXP(totalXP);
    return allLevels.where((l) => l.level > currentLevel.level).toList();
  }

  static const int maxLevel = 7;
}
