/// Achievement Categories
enum AchievementCategory {
  consistency,
  urgeResistance,
  spiritual,
  selfImprovement,
  comeback,
  legendary,
  hidden,
}

/// Achievement Rarity
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Legacy achievement types (kept for backward compatibility)
enum AchievementType {
  day1,
  day3,
  week1,
  month1,
  // New types
  day7,
  day14,
  day21,
  day30,
  day60,
  day90,
  day180,
  day365,
  urgeFirst,
  urge5,
  urge10,
  urgeNight,
  prayerDay,
  fajrWarrior,
  quranDaily,
  comebackFast,
  comebackPhoenix,
  perfectMonth,
  hiddenSecret1,
  hiddenSecret2,
}

class Achievement {
  final AchievementType type;
  final String id;
  final String title;
  final String description;
  final String benefits;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String icon;
  final int xpReward;
  final bool isHidden;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final int currentProgress;
  final int targetProgress;

  const Achievement({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.benefits,
    this.category = AchievementCategory.consistency,
    this.rarity = AchievementRarity.common,
    this.icon = '🏆',
    this.xpReward = 10,
    this.isHidden = false,
    this.isUnlocked = false,
    this.unlockedDate,
    this.currentProgress = 0,
    this.targetProgress = 1,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedDate,
    int? currentProgress,
  }) {
    return Achievement(
      type: type,
      id: id,
      title: title,
      description: description,
      benefits: benefits,
      category: category,
      rarity: rarity,
      icon: icon,
      xpReward: xpReward,
      isHidden: isHidden,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'id': id,
      'title': title,
      'description': description,
      'benefits': benefits,
      'category': category.toString(),
      'rarity': rarity.toString(),
      'icon': icon,
      'xpReward': xpReward,
      'isHidden': isHidden,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
    };
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (targetProgress == 0) return 0.0;
    return ((currentProgress / targetProgress) * 100).clamp(0.0, 100.0);
  }

  /// Check if achievement is completed (progress-wise)
  bool get isCompleted {
    return currentProgress >= targetProgress;
  }
}
