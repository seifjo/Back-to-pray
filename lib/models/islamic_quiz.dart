/// Topics shown on the Islamic Knowledge Quiz home screen.
enum QuizTopic {
  quran,
  hadith,
  seerah,
  prophets,
  history,
  general,
}

/// Difficulty filter applied when starting a session.
enum QuizDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// How a session is played.
enum QuizPlayMode {
  /// Fresh quiz for a topic + difficulty.
  practice,

  /// Replay previously incorrect questions (any topic).
  retryIncorrect,

  /// Review answered questions with explanations (no scoring pressure).
  revision,
}

/// One multiple-choice item with bilingual text and a documented source.
class QuizQuestion {
  final String id;
  final QuizTopic topic;
  final QuizDifficulty difficulty;
  final String promptEn;
  final String promptAr;
  final List<String> optionsEn;
  final List<String> optionsAr;
  final int correctIndex;
  final String explanationEn;
  final String explanationAr;
  final String sourceEn;
  final String sourceAr;

  /// Optional caution when scholarship differs on nuance (never the graded fact).
  final String? cautionEn;
  final String? cautionAr;

  const QuizQuestion({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.promptEn,
    required this.promptAr,
    required this.optionsEn,
    required this.optionsAr,
    required this.correctIndex,
    required this.explanationEn,
    required this.explanationAr,
    required this.sourceEn,
    required this.sourceAr,
    this.cautionEn,
    this.cautionAr,
  });

  String prompt(bool english) => english ? promptEn : promptAr;

  List<String> options(bool english) => english ? optionsEn : optionsAr;

  String explanation(bool english) =>
      english ? explanationEn : explanationAr;

  String source(bool english) => english ? sourceEn : sourceAr;

  String? caution(bool english) {
    if (english) return cautionEn;
    return cautionAr;
  }

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

/// One answered question inside a session.
class QuizAnswerRecord {
  final String questionId;
  final int selectedIndex;
  final bool correct;
  final DateTime answeredAt;

  const QuizAnswerRecord({
    required this.questionId,
    required this.selectedIndex,
    required this.correct,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'correct': correct,
        'answeredAt': answeredAt.toIso8601String(),
      };

  factory QuizAnswerRecord.fromJson(Map<String, dynamic> json) {
    return QuizAnswerRecord(
      questionId: json['questionId'] as String,
      selectedIndex: json['selectedIndex'] as int,
      correct: json['correct'] as bool,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }
}

/// In-progress or completed quiz session.
class QuizSession {
  final String id;
  final QuizTopic? topic;
  final QuizDifficulty? difficulty;
  final QuizPlayMode mode;
  final List<String> questionIds;
  final int cursor;
  final List<QuizAnswerRecord> answers;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;

  const QuizSession({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.mode,
    required this.questionIds,
    required this.cursor,
    required this.answers,
    required this.completed,
    required this.startedAt,
    this.completedAt,
  });

  int get total => questionIds.length;

  int get correctCount => answers.where((a) => a.correct).length;

  int get answeredCount => answers.length;

  bool get isComplete => completed || cursor >= questionIds.length;

  String? get currentQuestionId {
    if (isComplete || cursor < 0 || cursor >= questionIds.length) return null;
    return questionIds[cursor];
  }

  QuizAnswerRecord? answerFor(String questionId) {
    for (final answer in answers) {
      if (answer.questionId == questionId) return answer;
    }
    return null;
  }

  QuizSession copyWith({
    QuizTopic? topic,
    QuizDifficulty? difficulty,
    QuizPlayMode? mode,
    List<String>? questionIds,
    int? cursor,
    List<QuizAnswerRecord>? answers,
    bool? completed,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return QuizSession(
      id: id,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      mode: mode ?? this.mode,
      questionIds: questionIds ?? this.questionIds,
      cursor: cursor ?? this.cursor,
      answers: answers ?? this.answers,
      completed: completed ?? this.completed,
      startedAt: startedAt ?? this.startedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic?.name,
        'difficulty': difficulty?.name,
        'mode': mode.name,
        'questionIds': questionIds,
        'cursor': cursor,
        'answers': answers.map((a) => a.toJson()).toList(),
        'completed': completed,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'] as String,
      topic: _parseTopic(json['topic'] as String?),
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      mode: QuizPlayMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizPlayMode.practice,
      ),
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cursor: json['cursor'] as int? ?? 0,
      answers: (json['answers'] as List<dynamic>? ?? const [])
          .map((e) => QuizAnswerRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );
  }

  static QuizTopic? _parseTopic(String? name) {
    if (name == null) return null;
    for (final value in QuizTopic.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static QuizDifficulty? _parseDifficulty(String? name) {
    if (name == null) return null;
    for (final value in QuizDifficulty.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

/// Compact history entry for personal learning log (not a public ranking).
class QuizHistoryEntry {
  final String sessionId;
  final QuizTopic? topic;
  final QuizDifficulty? difficulty;
  final QuizPlayMode mode;
  final int correct;
  final int total;
  final DateTime completedAt;

  const QuizHistoryEntry({
    required this.sessionId,
    required this.topic,
    required this.difficulty,
    required this.mode,
    required this.correct,
    required this.total,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'topic': topic?.name,
        'difficulty': difficulty?.name,
        'mode': mode.name,
        'correct': correct,
        'total': total,
        'completedAt': completedAt.toIso8601String(),
      };

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> json) {
    return QuizHistoryEntry(
      sessionId: json['sessionId'] as String,
      topic: QuizSession._parseTopic(json['topic'] as String?),
      difficulty: QuizSession._parseDifficulty(json['difficulty'] as String?),
      mode: QuizPlayMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizPlayMode.practice,
      ),
      correct: json['correct'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
