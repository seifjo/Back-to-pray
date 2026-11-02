enum WorshipActivityKind {
  prayer,
  quran,
  adhkar,
  tasbeeh,
  learning,
  custom,
}

/// Distinguishes religious obligations the user chooses to track from personal goals.
enum WorshipGoalNature {
  obligation,
  personal,
}

class WorshipActivity {
  final String id;
  final WorshipActivityKind kind;
  final String titleEn;
  final String titleAr;
  final String? noteEn;
  final String? noteAr;
  final WorshipGoalNature nature;
  final bool enabled;
  final bool paused;
  final int targetCount;
  final int sortOrder;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;
  /// Optional deep-link: quran | adhkar | tasbeeh
  final String? shortcut;

  const WorshipActivity({
    required this.id,
    required this.kind,
    required this.titleEn,
    required this.titleAr,
    this.noteEn,
    this.noteAr,
    required this.nature,
    this.enabled = true,
    this.paused = false,
    this.targetCount = 1,
    this.sortOrder = 0,
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
    this.shortcut,
  });

  String title(bool english) => english ? titleEn : titleAr;

  String? note(bool english) {
    if (english) {
      return noteEn?.isNotEmpty == true ? noteEn : noteAr;
    }
    return noteAr?.isNotEmpty == true ? noteAr : noteEn;
  }

  bool get isObligation => nature == WorshipGoalNature.obligation;

  bool get isActiveOnDashboard => enabled && !paused;

  WorshipActivity copyWith({
    WorshipActivityKind? kind,
    String? titleEn,
    String? titleAr,
    String? noteEn,
    String? noteAr,
    WorshipGoalNature? nature,
    bool? enabled,
    bool? paused,
    int? targetCount,
    int? sortOrder,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? shortcut,
    bool clearShortcut = false,
    bool clearReminderTime = false,
  }) {
    return WorshipActivity(
      id: id,
      kind: kind ?? this.kind,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      nature: nature ?? this.nature,
      enabled: enabled ?? this.enabled,
      paused: paused ?? this.paused,
      targetCount: targetCount ?? this.targetCount,
      sortOrder: sortOrder ?? this.sortOrder,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour:
          clearReminderTime ? null : (reminderHour ?? this.reminderHour),
      reminderMinute:
          clearReminderTime ? null : (reminderMinute ?? this.reminderMinute),
      shortcut: clearShortcut ? null : (shortcut ?? this.shortcut),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'noteEn': noteEn,
        'noteAr': noteAr,
        'nature': nature.name,
        'enabled': enabled,
        'paused': paused,
        'targetCount': targetCount,
        'sortOrder': sortOrder,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'shortcut': shortcut,
      };

  factory WorshipActivity.fromJson(Map<String, dynamic> json) {
    return WorshipActivity(
      id: json['id'] as String,
      kind: WorshipActivityKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => WorshipActivityKind.custom,
      ),
      titleEn: json['titleEn'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      noteEn: json['noteEn'] as String?,
      noteAr: json['noteAr'] as String?,
      nature: WorshipGoalNature.values.firstWhere(
        (value) => value.name == json['nature'],
        orElse: () => WorshipGoalNature.personal,
      ),
      enabled: json['enabled'] as bool? ?? true,
      paused: json['paused'] as bool? ?? false,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 1,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt(),
      reminderMinute: (json['reminderMinute'] as num?)?.toInt(),
      shortcut: json['shortcut'] as String?,
    );
  }
}

class WorshipDayLog {
  final String dateKey;
  final Map<String, int> completions;

  const WorshipDayLog({
    required this.dateKey,
    this.completions = const {},
  });

  int countFor(String activityId) => completions[activityId] ?? 0;

  bool isComplete(WorshipActivity activity) {
    return countFor(activity.id) >= activity.targetCount.clamp(1, 99);
  }

  WorshipDayLog withToggle(WorshipActivity activity) {
    final next = Map<String, int>.from(completions);
    final current = next[activity.id] ?? 0;
    final target = activity.targetCount.clamp(1, 99);
    if (current >= target) {
      next.remove(activity.id);
    } else {
      next[activity.id] = target;
    }
    return WorshipDayLog(dateKey: dateKey, completions: next);
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'completions': completions,
      };

  factory WorshipDayLog.fromJson(Map<String, dynamic> json) {
    final raw = json['completions'];
    final map = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        map['$key'] = (value as num?)?.toInt() ?? 0;
      });
    }
    return WorshipDayLog(
      dateKey: json['dateKey'] as String? ?? '',
      completions: map,
    );
  }
}

class WorshipPeriodSummary {
  final int daysTracked;
  final int completedSlots;
  final int possibleSlots;
  final Map<String, int> completedByActivity;

  const WorshipPeriodSummary({
    required this.daysTracked,
    required this.completedSlots,
    required this.possibleSlots,
    required this.completedByActivity,
  });

  double get rate =>
      possibleSlots == 0 ? 0 : completedSlots / possibleSlots;
}
