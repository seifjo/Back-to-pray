/// Quran Race Room Models
/// Data models for the real-time Quran competition system

class QuranRaceRoom {
  final String id;
  final String name;
  final String creatorId;
  final String creatorName;
  final bool isPublic;
  final String goal; // 'full_khatma' or 'specific_juz'
  final int? targetJuz;
  final DateTime createdAt;
  final Map<String, RoomParticipant> participants;

  const QuranRaceRoom({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.creatorName,
    required this.isPublic,
    required this.goal,
    this.targetJuz,
    required this.createdAt,
    this.participants = const {},
  });

  QuranRaceRoom copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? creatorName,
    bool? isPublic,
    String? goal,
    int? targetJuz,
    DateTime? createdAt,
    Map<String, RoomParticipant>? participants,
  }) {
    return QuranRaceRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      isPublic: isPublic ?? this.isPublic,
      goal: goal ?? this.goal,
      targetJuz: targetJuz ?? this.targetJuz,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'isPublic': isPublic,
      'goal': goal,
      'targetJuz': targetJuz,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuranRaceRoom.fromJson(Map<String, dynamic> json) {
    final participantsMap = <String, RoomParticipant>{};
    if (json['participants'] != null) {
      final participantsJson = Map<String, dynamic>.from(json['participants'] as Map);
      participantsJson.forEach((key, value) {
        participantsMap[key] = RoomParticipant.fromJson(Map<String, dynamic>.from(value as Map));
      });
    }
    return QuranRaceRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      goal: json['goal'] as String? ?? 'full_khatma',
      targetJuz: json['targetJuz'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      participants: participantsMap,
    );
  }

  /// Get goal display text in Arabic
  String get goalDisplayText {
    if (goal == 'specific_juz' && targetJuz != null) {
      return 'ختم الجزء $targetJuz';
    }
    return 'ختم القرآن الكريم (30 جزء)';
  }

  /// Get sorted leaderboard (by completion percentage descending)
  List<MapEntry<String, RoomParticipant>> get leaderboard {
    final entries = participants.entries.toList();
    entries.sort((a, b) => b.value.completionPercentage.compareTo(a.value.completionPercentage));
    return entries;
  }
}

class RoomParticipant {
  final String odId;
  final String displayName;
  final int currentJuz;
  final int currentSurahNumber;
  final String currentSurahName;
  final int currentAyah;
  final double completionPercentage;
  final int totalPagesRead;
  final bool isCurrentlyReading;
  final DateTime? lastActivity;
  final DateTime joinedAt;
  final List<String> badges;

  const RoomParticipant({
    required this.odId,
    required this.displayName,
    this.currentJuz = 0,
    this.currentSurahNumber = 1,
    this.currentSurahName = 'الفاتحة',
    this.currentAyah = 0,
    this.completionPercentage = 0.0,
    this.totalPagesRead = 0,
    this.isCurrentlyReading = false,
    this.lastActivity,
    required this.joinedAt,
    this.badges = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'odId': odId,
      'displayName': displayName,
      'currentJuz': currentJuz,
      'currentSurahNumber': currentSurahNumber,
      'currentSurahName': currentSurahName,
      'currentAyah': currentAyah,
      'completionPercentage': completionPercentage,
      'totalPagesRead': totalPagesRead,
      'isCurrentlyReading': isCurrentlyReading,
      'lastActivity': lastActivity?.toIso8601String(),
      'joinedAt': joinedAt.toIso8601String(),
      'badges': badges,
    };
  }

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      odId: json['odId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'مجهول',
      currentJuz: json['currentJuz'] as int? ?? 0,
      currentSurahNumber: json['currentSurahNumber'] as int? ?? 1,
      currentSurahName: json['currentSurahName'] as String? ?? 'الفاتحة',
      currentAyah: json['currentAyah'] as int? ?? 0,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      totalPagesRead: json['totalPagesRead'] as int? ?? 0,
      isCurrentlyReading: json['isCurrentlyReading'] as bool? ?? false,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      badges: json['badges'] != null
          ? List<String>.from(json['badges'] as List)
          : [],
    );
  }

  /// Check if finished the full Quran
  bool get hasCompletedKhatma => completionPercentage >= 100.0;
}
