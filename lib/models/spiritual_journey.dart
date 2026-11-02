import '../models/active_journey.dart';

class SpiritualJourney {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String objectiveAr;
  final String objectiveEn;
  final int durationDays;
  final String icon;
  final List<List<String>> tasksAr;
  final List<List<String>> tasksEn;
  final List<int> milestones;
  final String disclaimerAr;
  final String disclaimerEn;

  const SpiritualJourney({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.objectiveAr,
    required this.objectiveEn,
    required this.durationDays,
    required this.icon,
    required this.tasksAr,
    required this.tasksEn,
    required this.milestones,
    this.disclaimerAr =
        'خطة شخصية اختيارية للتذكير، وليست عبادة مفروضة بعينها إلا ما ثبت أصله شرعاً كالصلاة والذكر.',
    this.disclaimerEn =
        'A personal optional plan for encouragement—not a newly prescribed act of worship, except where the underlying practice is already established (such as prayer or remembrance).',
  });

  String title(bool english) => english ? titleEn : titleAr;
  String description(bool english) => english ? descriptionEn : descriptionAr;
  String objective(bool english) => english ? objectiveEn : objectiveAr;
  String disclaimer(bool english) => english ? disclaimerEn : disclaimerAr;

  List<String> tasksForDay(int dayIndex, bool english) {
    final source = english ? tasksEn : tasksAr;
    if (source.isEmpty) return const [];
    return source[dayIndex.clamp(0, source.length - 1)];
  }
}

class SpiritualJourneyProgress {
  final String journeyId;
  final DateTime startDate;
  final JourneyStatus status;
  final List<String> completedDays;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;

  const SpiritualJourneyProgress({
    required this.journeyId,
    required this.startDate,
    this.status = JourneyStatus.active,
    this.completedDays = const [],
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
  });

  SpiritualJourneyProgress copyWith({
    DateTime? startDate,
    JourneyStatus? status,
    List<String>? completedDays,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool clearReminderTime = false,
  }) {
    return SpiritualJourneyProgress(
      journeyId: journeyId,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      completedDays: completedDays ?? this.completedDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour:
          clearReminderTime ? null : (reminderHour ?? this.reminderHour),
      reminderMinute:
          clearReminderTime ? null : (reminderMinute ?? this.reminderMinute),
    );
  }

  Map<String, dynamic> toJson() => {
        'journeyId': journeyId,
        'startDate': startDate.toIso8601String(),
        'status': status.name,
        'completedDays': completedDays,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  factory SpiritualJourneyProgress.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? 'active';
    return SpiritualJourneyProgress(
      journeyId: json['journeyId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      status: JourneyStatus.values.firstWhere(
        (status) => status.name == statusName,
        orElse: () => JourneyStatus.active,
      ),
      completedDays: (json['completedDays'] as List<dynamic>? ?? [])
          .map((day) => day.toString())
          .toList(),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt(),
      reminderMinute: (json['reminderMinute'] as num?)?.toInt(),
    );
  }
}

/// Calendar day index from the start date, capped at the last day.
int spiritualDayIndex(DateTime start, DateTime now, int durationDays) {
  final startDay = DateTime(start.year, start.month, start.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(startDay).inDays;
  if (durationDays <= 0) return 0;
  if (diff < 0) return 0;
  if (diff >= durationDays) return durationDays - 1;
  return diff;
}

String spiritualDayKey(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  final month = day.month.toString().padLeft(2, '0');
  final dayText = day.day.toString().padLeft(2, '0');
  return '${day.year}-$month-$dayText';
}

bool hasEarlierUnmarkedDay({
  required DateTime start,
  required DateTime now,
  required int durationDays,
  required List<String> completedDays,
}) {
  final index = spiritualDayIndex(start, now, durationDays);
  for (var i = 0; i < index; i++) {
    final key = spiritualDayKey(
      DateTime(start.year, start.month, start.day).add(Duration(days: i)),
    );
    if (!completedDays.contains(key)) return true;
  }
  return false;
}
