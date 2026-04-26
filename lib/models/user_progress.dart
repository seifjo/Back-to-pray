// User Progress Model
// Comprehensive tracking of user's recovery journey progress
class UserProgress {
  // Streak tracking
  final int currentStreak;
  final DateTime? streakStartDate;
  final int longestStreak;
  final int totalCleanDays;

  // Journey tracking
  final String? activeJourneyId;
  final DateTime? journeyStartDate;
  final DateTime? lastCheckIn;

  // Gamification
  final int totalXP;
  final int currentLevel;
  final int recoveryPoints;

  // Brain recovery stats (0-100 percentages)
  final double dopamineBalance;
  final double focusImprovement;
  final double energyLevel;
  final double moodStability;

  const UserProgress({
    this.currentStreak = 0,
    this.streakStartDate,
    this.longestStreak = 0,
    this.totalCleanDays = 0,
    this.activeJourneyId,
    this.journeyStartDate,
    this.lastCheckIn,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.recoveryPoints = 0,
    this.dopamineBalance = 0.0,
    this.focusImprovement = 0.0,
    this.energyLevel = 0.0,
    this.moodStability = 0.0,
  });

  /// Create a copy with modified fields
  UserProgress copyWith({
    int? currentStreak,
    DateTime? streakStartDate,
    int? longestStreak,
    int? totalCleanDays,
    String? activeJourneyId,
    DateTime? journeyStartDate,
    DateTime? lastCheckIn,
    int? totalXP,
    int? currentLevel,
    int? recoveryPoints,
    double? dopamineBalance,
    double? focusImprovement,
    double? energyLevel,
    double? moodStability,
  }) {
    return UserProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      activeJourneyId: activeJourneyId ?? this.activeJourneyId,
      journeyStartDate: journeyStartDate ?? this.journeyStartDate,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      recoveryPoints: recoveryPoints ?? this.recoveryPoints,
      dopamineBalance: dopamineBalance ?? this.dopamineBalance,
      focusImprovement: focusImprovement ?? this.focusImprovement,
      energyLevel: energyLevel ?? this.energyLevel,
      moodStability: moodStability ?? this.moodStability,
    );
  }

  /// Get brain recovery stats as a map
  Map<String, double> get brainRecoveryStats => {
        'dopamine': dopamineBalance,
        'focus': focusImprovement,
        'energy': energyLevel,
        'mood': moodStability,
      };

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'streakStartDate': streakStartDate?.toIso8601String(),
      'longestStreak': longestStreak,
      'totalCleanDays': totalCleanDays,
      'activeJourneyId': activeJourneyId,
      'journeyStartDate': journeyStartDate?.toIso8601String(),
      'lastCheckIn': lastCheckIn?.toIso8601String(),
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'recoveryPoints': recoveryPoints,
      'dopamineBalance': dopamineBalance,
      'focusImprovement': focusImprovement,
      'energyLevel': energyLevel,
      'moodStability': moodStability,
    };
  }

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentStreak: json['currentStreak'] as int? ?? 0,
      streakStartDate: json['streakStartDate'] != null
          ? DateTime.parse(json['streakStartDate'] as String)
          : null,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalCleanDays: json['totalCleanDays'] as int? ?? 0,
      activeJourneyId: json['activeJourneyId'] as String?,
      journeyStartDate: json['journeyStartDate'] != null
          ? DateTime.parse(json['journeyStartDate'] as String)
          : null,
      lastCheckIn: json['lastCheckIn'] != null
          ? DateTime.parse(json['lastCheckIn'] as String)
          : null,
      totalXP: json['totalXP'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      recoveryPoints: json['recoveryPoints'] as int? ?? 0,
      dopamineBalance: (json['dopamineBalance'] as num?)?.toDouble() ?? 0.0,
      focusImprovement: (json['focusImprovement'] as num?)?.toDouble() ?? 0.0,
      energyLevel: (json['energyLevel'] as num?)?.toDouble() ?? 0.0,
      moodStability: (json['moodStability'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProgress &&
        other.currentStreak == currentStreak &&
        other.streakStartDate == streakStartDate &&
        other.longestStreak == longestStreak &&
        other.totalCleanDays == totalCleanDays &&
        other.activeJourneyId == activeJourneyId &&
        other.journeyStartDate == journeyStartDate &&
        other.lastCheckIn == lastCheckIn &&
        other.totalXP == totalXP &&
        other.currentLevel == currentLevel &&
        other.recoveryPoints == recoveryPoints &&
        other.dopamineBalance == dopamineBalance &&
        other.focusImprovement == focusImprovement &&
        other.energyLevel == energyLevel &&
        other.moodStability == moodStability;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStreak,
      streakStartDate,
      longestStreak,
      totalCleanDays,
      activeJourneyId,
      journeyStartDate,
      lastCheckIn,
      totalXP,
      currentLevel,
      recoveryPoints,
      dopamineBalance,
      focusImprovement,
      energyLevel,
      moodStability,
    );
  }
}
