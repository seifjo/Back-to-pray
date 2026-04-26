/// Active Journey Model
/// Tracks user's current recovery journey
class ActiveJourney {
  final String journeyId;
  final DateTime startDate;
  final int currentStreak;
  final int totalDays;
  final DateTime? lastCheckIn;
  final List<JourneyCheckIn> checkIns;
  final JourneyStatus status;

  const ActiveJourney({
    required this.journeyId,
    required this.startDate,
    this.currentStreak = 0,
    this.totalDays = 0,
    this.lastCheckIn,
    this.checkIns = const [],
    this.status = JourneyStatus.active,
  });

  /// Create a copy with modified fields
  ActiveJourney copyWith({
    String? journeyId,
    DateTime? startDate,
    int? currentStreak,
    int? totalDays,
    DateTime? lastCheckIn,
    List<JourneyCheckIn>? checkIns,
    JourneyStatus? status,
  }) {
    return ActiveJourney(
      journeyId: journeyId ?? this.journeyId,
      startDate: startDate ?? this.startDate,
      currentStreak: currentStreak ?? this.currentStreak,
      totalDays: totalDays ?? this.totalDays,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkIns: checkIns ?? this.checkIns,
      status: status ?? this.status,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'journeyId': journeyId,
      'startDate': startDate.toIso8601String(),
      'currentStreak': currentStreak,
      'totalDays': totalDays,
      'lastCheckIn': lastCheckIn?.toIso8601String(),
      'checkIns': checkIns.map((e) => e.toJson()).toList(),
      'status': status.toString(),
    };
  }

  /// Create from JSON
  factory ActiveJourney.fromJson(Map<String, dynamic> json) {
    return ActiveJourney(
      journeyId: json['journeyId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
      lastCheckIn: json['lastCheckIn'] != null
          ? DateTime.parse(json['lastCheckIn'] as String)
          : null,
      checkIns: (json['checkIns'] as List<dynamic>?)
              ?.map((e) => JourneyCheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: JourneyStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => JourneyStatus.active,
      ),
    );
  }

  /// Get days since start
  int getDaysSinceStart() {
    return DateTime.now().difference(startDate).inDays;
  }

  /// Check if today was logged
  bool isTodayLogged() {
    if (lastCheckIn == null) return false;
    final today = DateTime.now();
    return lastCheckIn!.year == today.year &&
        lastCheckIn!.month == today.month &&
        lastCheckIn!.day == today.day;
  }
}

/// Journey Check-In Record
class JourneyCheckIn {
  final DateTime date;
  final bool wasSuccessful;
  final String? note;

  const JourneyCheckIn({
    required this.date,
    required this.wasSuccessful,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'wasSuccessful': wasSuccessful,
      'note': note,
    };
  }

  factory JourneyCheckIn.fromJson(Map<String, dynamic> json) {
    return JourneyCheckIn(
      date: DateTime.parse(json['date'] as String),
      wasSuccessful: json['wasSuccessful'] as bool,
      note: json['note'] as String?,
    );
  }
}

/// Journey Status
enum JourneyStatus {
  active,
  paused,
  completed,
  abandoned,
}
