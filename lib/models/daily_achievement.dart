// Daily Achievement Model
// Tracks daily activities separate from journey milestones

enum DailyAchievementCategory {
  prayer,
  quran,
  adhkar,
  sleep,
  exercise,
}

extension DailyAchievementCategoryExtension on DailyAchievementCategory {
  String get arabicName {
    switch (this) {
      case DailyAchievementCategory.prayer:
        return 'الصلاة';
      case DailyAchievementCategory.quran:
        return 'القرآن';
      case DailyAchievementCategory.adhkar:
        return 'الأذكار';
      case DailyAchievementCategory.sleep:
        return 'النوم';
      case DailyAchievementCategory.exercise:
        return 'الرياضة';
    }
  }

  String get icon {
    switch (this) {
      case DailyAchievementCategory.prayer:
        return '🕌';
      case DailyAchievementCategory.quran:
        return '📖';
      case DailyAchievementCategory.adhkar:
        return '🤲';
      case DailyAchievementCategory.sleep:
        return '😴';
      case DailyAchievementCategory.exercise:
        return '💪';
    }
  }
}

class DailyAchievement {
  final String id;
  final String title;
  final String description;
  final DailyAchievementCategory category;
  final int xpReward;
  final int pointsReward;
  final bool isCompleted;
  final DateTime? completedDate;
  final int currentStreak;
  final int bestStreak;

  const DailyAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.xpReward = 10,
    this.pointsReward = 5,
    this.isCompleted = false,
    this.completedDate,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  DailyAchievement copyWith({
    bool? isCompleted,
    DateTime? completedDate,
    int? currentStreak,
    int? bestStreak,
  }) {
    return DailyAchievement(
      id: id,
      title: title,
      description: description,
      category: category,
      xpReward: xpReward,
      pointsReward: pointsReward,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'xpReward': xpReward,
      'pointsReward': pointsReward,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  /// Create from JSON
  factory DailyAchievement.fromJson(Map<String, dynamic> json) {
    return DailyAchievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: DailyAchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => DailyAchievementCategory.prayer,
      ),
      xpReward: json['xpReward'] as int? ?? 10,
      pointsReward: json['pointsReward'] as int? ?? 5,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }
}
