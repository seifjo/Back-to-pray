/// XP Rewards Configuration
/// Defines XP rewards for different actions
class XPRewards {
  // ========================================
  // BASE XP REWARDS
  // ========================================

  /// XP for completing a clean day
  static const int cleanDay = 10;

  /// XP for resisting an urge successfully
  static const int urgeResisted = 25;

  /// XP for completing a prayer
  static const int prayerCompleted = 5;

  /// XP for opening the app daily
  static const int dailyAppOpen = 3;

  /// XP for completing a journey task
  static const int taskCompleted = 8;

  /// XP for reading Quran
  static const int quranRead = 7;

  /// XP for daily dhikr completion
  static const int dhikrCompleted = 5;

  // ========================================
  // BONUS MULTIPLIERS
  // ========================================

  /// Bonus multiplier for streak milestones
  static double getStreakBonus(int streak) {
    if (streak >= 90) return 3.0;
    if (streak >= 60) return 2.5;
    if (streak >= 30) return 2.0;
    if (streak >= 14) return 1.5;
    if (streak >= 7) return 1.25;
    return 1.0;
  }

  /// Bonus for completing all 5 prayers in a day
  static const int allPrayersBonus = 20;

  /// Bonus for night urge resistance (after 10 PM)
  static const int nightUrgeBonus = 10;

  /// Bonus for early morning app usage (before 6 AM)
  static const int earlyMorningBonus = 5;

  // ========================================
  // MILESTONE BONUSES
  // ========================================

  /// Get bonus XP for reaching streak milestones
  static int getStreakMilestoneBonus(int streak) {
    switch (streak) {
      case 3:
        return 20;
      case 7:
        return 50;
      case 14:
        return 75;
      case 21:
        return 100;
      case 30:
        return 200;
      case 60:
        return 300;
      case 90:
        return 500;
      case 180:
        return 1000;
      case 365:
        return 2000;
      default:
        return 0;
    }
  }

  // ========================================
  // SPECIAL XP REWARDS
  // ========================================

  /// XP for fast comeback after relapse (within 24 hours)
  static const int fastComeback = 50;

  /// XP for achieving perfect day (all prayers + no urges + tasks)
  static const int perfectDay = 50;

  /// XP for helping others (future feature)
  static const int helpingOthers = 30;

  // ========================================
  // RECOVERY POINTS (CURRENCY)
  // ========================================

  /// Recovery points earned per clean day
  static const int recoveryPointsPerDay = 5;

  /// Recovery points for resisting urge
  static const int recoveryPointsUrge = 10;

  /// Recovery points for level up
  static int getRecoveryPointsForLevel(int newLevel) {
    return newLevel * 50;
  }

  /// Recovery points for achievement unlocked
  static int getRecoveryPointsForRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return 10;
      case 'rare':
        return 25;
      case 'epic':
        return 50;
      case 'legendary':
        return 100;
      default:
        return 5;
    }
  }

  // ========================================
  // XP CALCULATION HELPERS
  // ========================================

  /// Calculate total XP for an action with bonuses
  static int calculateTotalXP({
    required int baseXP,
    int streak = 0,
    bool isNightTime = false,
    bool isEarlyMorning = false,
  }) {
    double multiplier = getStreakBonus(streak);
    int total = (baseXP * multiplier).round();

    if (isNightTime) total += nightUrgeBonus;
    if (isEarlyMorning) total += earlyMorningBonus;

    return total;
  }

  /// Calculate XP for a clean day including bonuses
  static int calculateCleanDayXP({
    required int streak,
    bool allPrayersCompleted = false,
  }) {
    int xp = calculateTotalXP(baseXP: cleanDay, streak: streak);

    // Check for milestone bonus
    xp += getStreakMilestoneBonus(streak);

    // Add prayer bonus
    if (allPrayersCompleted) {
      xp += allPrayersBonus;
    }

    return xp;
  }

  /// Calculate XP for resisting an urge
  static int calculateUrgeResistanceXP({
    required int streak,
    required DateTime urgeTime,
  }) {
    final isNight = urgeTime.hour >= 22 || urgeTime.hour <= 5;

    return calculateTotalXP(
      baseXP: urgeResisted,
      streak: streak,
      isNightTime: isNight,
    );
  }
}
