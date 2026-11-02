enum AsmaSourceKind {
  quran,
  sunnah,
}

/// Which shelf a Name belongs to in Al Noor’s library.
enum AsmaCollectionKind {
  /// Ranked 1–99 Quranic listing (SurahQuran educational order).
  primary,

  /// Compound Beautiful Names occurring in the Quran (shown after 99).
  quranCompound,

  /// Selected Names reported from authentic Sunnah (separate section).
  sunnahExtra,
}

class DivineName {
  final String id;
  final int index;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningAr;
  final String explanationEn;
  final String explanationAr;
  final AsmaSourceKind sourceKind;
  final AsmaCollectionKind collection;
  final String evidenceNoteEn;
  final String evidenceNoteAr;
  final List<String> themeIds;

  const DivineName({
    required this.id,
    required this.index,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningAr,
    required this.explanationEn,
    required this.explanationAr,
    required this.sourceKind,
    required this.collection,
    required this.evidenceNoteEn,
    required this.evidenceNoteAr,
    this.themeIds = const [],
  });

  String meaning(bool english) => english ? meaningEn : meaningAr;

  String explanation(bool english) =>
      english || explanationAr.isEmpty ? explanationEn : explanationAr;

  String evidenceNote(bool english) =>
      english ? evidenceNoteEn : evidenceNoteAr;

  bool get fromQuran => sourceKind == AsmaSourceKind.quran;

  bool get isPrimary => collection == AsmaCollectionKind.primary;
}

class AsmaTheme {
  final String id;
  final String nameEn;
  final String nameAr;

  const AsmaTheme({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  String name(bool english) => english ? nameEn : nameAr;
}

class AsmaLearningSession {
  final String id;
  final List<String> nameIds;
  final int cursor;
  final bool quizMode;
  final int quizCorrect;
  final int quizAnswered;
  final DateTime startedAt;

  const AsmaLearningSession({
    required this.id,
    required this.nameIds,
    required this.cursor,
    required this.quizMode,
    required this.quizCorrect,
    required this.quizAnswered,
    required this.startedAt,
  });

  AsmaLearningSession copyWith({
    List<String>? nameIds,
    int? cursor,
    bool? quizMode,
    int? quizCorrect,
    int? quizAnswered,
  }) {
    return AsmaLearningSession(
      id: id,
      nameIds: nameIds ?? this.nameIds,
      cursor: cursor ?? this.cursor,
      quizMode: quizMode ?? this.quizMode,
      quizCorrect: quizCorrect ?? this.quizCorrect,
      quizAnswered: quizAnswered ?? this.quizAnswered,
      startedAt: startedAt,
    );
  }

  bool get isComplete =>
      nameIds.isEmpty || cursor >= nameIds.length;

  double get quizAccuracy =>
      quizAnswered == 0 ? 0 : quizCorrect / quizAnswered;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameIds': nameIds,
        'cursor': cursor,
        'quizMode': quizMode,
        'quizCorrect': quizCorrect,
        'quizAnswered': quizAnswered,
        'startedAt': startedAt.toIso8601String(),
      };

  factory AsmaLearningSession.fromJson(Map<String, dynamic> json) {
    return AsmaLearningSession(
      id: json['id'] as String,
      nameIds: (json['nameIds'] as List).cast<String>(),
      cursor: json['cursor'] as int? ?? 0,
      quizMode: json['quizMode'] as bool? ?? false,
      quizCorrect: json['quizCorrect'] as int? ?? 0,
      quizAnswered: json['quizAnswered'] as int? ?? 0,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
