import 'package:flutter/foundation.dart';

import '../core/services/islamic_quiz_store.dart';
import '../data/islamic_quiz_catalog.dart';
import '../models/islamic_quiz.dart';

class IslamicQuizProvider extends ChangeNotifier {
  IslamicQuizProvider({
    IslamicQuizStore? store,
    DateTime Function()? clock,
  })  : _store = store ?? IslamicQuizStore(),
        _clock = clock ?? DateTime.now;

  final IslamicQuizStore _store;
  final DateTime Function() _clock;

  bool _loading = true;
  String? _error;
  QuizDifficulty _selectedDifficulty = QuizDifficulty.beginner;
  QuizSession? _session;
  int? _pendingSelection;
  bool _revealed = false;
  List<QuizHistoryEntry> _history = const [];
  Set<String> _incorrectIds = {};
  Set<String> _correctIds = {};
  Set<String> _topicsReviewed = {};
  int _lifetimeCorrect = 0;
  int _lifetimeAnswered = 0;

  bool get loading => _loading;
  String? get error => _error;
  QuizDifficulty get selectedDifficulty => _selectedDifficulty;
  QuizSession? get session => _session;
  int? get pendingSelection => _pendingSelection;
  bool get revealed => _revealed;
  List<QuizHistoryEntry> get history => _history;
  Set<String> get incorrectIds => _incorrectIds;
  Set<String> get correctIds => _correctIds;
  Set<String> get topicsReviewed => _topicsReviewed;
  int get lifetimeCorrect => _lifetimeCorrect;
  int get lifetimeAnswered => _lifetimeAnswered;
  String get attributionEn => IslamicQuizCatalog.attributionEn;
  String get attributionAr => IslamicQuizCatalog.attributionAr;
  List<QuizTopicInfo> get topics => IslamicQuizCatalog.topics;

  int get incorrectCount => _incorrectIds.length;

  QuizQuestion? get currentQuestion {
    final id = _session?.currentQuestionId;
    if (id == null) return null;
    return IslamicQuizCatalog.byId(id);
  }

  bool get hasActiveIncompleteSession =>
      _session != null && !_session!.isComplete;

  bool get canRetryIncorrect => _incorrectIds.isNotEmpty;

  bool get canRevise => _correctIds.isNotEmpty || _incorrectIds.isNotEmpty;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (IslamicQuizCatalog.all.isEmpty) {
        throw StateError('Quiz catalog is empty');
      }
      for (final q in IslamicQuizCatalog.all) {
        if (q.optionsEn.length != 4 || q.optionsAr.length != 4) {
          throw StateError('Question ${q.id} must have 4 options');
        }
        if (q.correctIndex < 0 || q.correctIndex > 3) {
          throw StateError('Question ${q.id} has invalid correctIndex');
        }
        if (q.sourceEn.trim().isEmpty || q.sourceAr.trim().isEmpty) {
          throw StateError('Question ${q.id} missing source');
        }
      }
      _session = await _store.loadActiveSession();
      _history = await _store.loadHistory();
      _incorrectIds = await _store.loadIncorrectIds();
      _correctIds = await _store.loadCorrectIds();
      _topicsReviewed = await _store.loadTopicsReviewed();
      _lifetimeCorrect = await _store.loadLifetimeCorrect();
      _lifetimeAnswered = await _store.loadLifetimeAnswered();
      _pendingSelection = null;
      _revealed = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setDifficulty(QuizDifficulty difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  int questionCountFor(QuizTopic topic, QuizDifficulty difficulty) {
    return IslamicQuizCatalog.forTopic(topic, difficulty: difficulty).length;
  }

  Future<bool> startTopicQuiz(QuizTopic topic) async {
    final pool = IslamicQuizCatalog.forTopic(
      topic,
      difficulty: _selectedDifficulty,
    );
    if (pool.isEmpty) return false;
    final ids = pool.map((q) => q.id).toList()..shuffle();
    _session = QuizSession(
      id: 'quiz_${_clock().millisecondsSinceEpoch}',
      topic: topic,
      difficulty: _selectedDifficulty,
      mode: QuizPlayMode.practice,
      questionIds: ids,
      cursor: 0,
      answers: const [],
      completed: false,
      startedAt: _clock(),
    );
    _pendingSelection = null;
    _revealed = false;
    await _store.saveActiveSession(_session);
    notifyListeners();
    return true;
  }

  Future<bool> startRetryIncorrect() async {
    final ids = _incorrectIds.toList();
    if (ids.isEmpty) return false;
    ids.shuffle();
    _session = QuizSession(
      id: 'retry_${_clock().millisecondsSinceEpoch}',
      topic: null,
      difficulty: null,
      mode: QuizPlayMode.retryIncorrect,
      questionIds: ids,
      cursor: 0,
      answers: const [],
      completed: false,
      startedAt: _clock(),
    );
    _pendingSelection = null;
    _revealed = false;
    await _store.saveActiveSession(_session);
    notifyListeners();
    return true;
  }

  Future<bool> startRevision({int maxItems = 20}) async {
    final reviewed = <String>{
      ..._correctIds,
      ..._incorrectIds,
    }.toList();
    if (reviewed.isEmpty) return false;
    reviewed.shuffle();
    final ids = reviewed.take(maxItems).toList();
    _session = QuizSession(
      id: 'revision_${_clock().millisecondsSinceEpoch}',
      topic: null,
      difficulty: null,
      mode: QuizPlayMode.revision,
      questionIds: ids,
      cursor: 0,
      answers: const [],
      completed: false,
      startedAt: _clock(),
    );
    _pendingSelection = null;
    _revealed = false;
    await _store.saveActiveSession(_session);
    notifyListeners();
    return true;
  }

  void selectOption(int index) {
    if (_revealed || _session == null || _session!.isComplete) return;
    if (index < 0 || index > 3) return;
    _pendingSelection = index;
    notifyListeners();
  }

  /// Validates the pending selection, records score, and reveals explanation.
  Future<bool?> submitAnswer() async {
    final session = _session;
    final question = currentQuestion;
    final selected = _pendingSelection;
    if (session == null || question == null || selected == null || _revealed) {
      return null;
    }

    final correct = question.isCorrect(selected);
    final record = QuizAnswerRecord(
      questionId: question.id,
      selectedIndex: selected,
      correct: correct,
      answeredAt: _clock(),
    );

    final answers = [...session.answers, record];
    _session = session.copyWith(answers: answers);
    _revealed = true;

    if (session.mode != QuizPlayMode.revision) {
      _lifetimeAnswered += 1;
      if (correct) {
        _lifetimeCorrect += 1;
        _correctIds = {..._correctIds, question.id};
        _incorrectIds = {..._incorrectIds}..remove(question.id);
      } else {
        _incorrectIds = {..._incorrectIds, question.id};
      }
      await _store.saveLifetime(
        correct: _lifetimeCorrect,
        answered: _lifetimeAnswered,
      );
      await _store.saveCorrectIds(_correctIds);
      await _store.saveIncorrectIds(_incorrectIds);
    } else {
      // Revision still tracks personal review, but does not change scores.
      if (correct) {
        _correctIds = {..._correctIds, question.id};
        _incorrectIds = {..._incorrectIds}..remove(question.id);
      } else {
        _incorrectIds = {..._incorrectIds, question.id};
      }
      await _store.saveCorrectIds(_correctIds);
      await _store.saveIncorrectIds(_incorrectIds);
    }

    if (session.topic != null) {
      _topicsReviewed = {..._topicsReviewed, session.topic!.name};
      await _store.saveTopicsReviewed(_topicsReviewed);
    }

    await _store.saveActiveSession(_session);
    notifyListeners();
    return correct;
  }

  Future<void> nextQuestion() async {
    final session = _session;
    if (session == null || !_revealed) return;

    final nextCursor = session.cursor + 1;
    if (nextCursor >= session.questionIds.length) {
      await _completeSession();
      return;
    }

    _session = session.copyWith(cursor: nextCursor);
    _pendingSelection = null;
    _revealed = false;
    await _store.saveActiveSession(_session);
    notifyListeners();
  }

  Future<void> _completeSession() async {
    final session = _session;
    if (session == null) return;

    final completedAt = _clock();
    _session = session.copyWith(
      completed: true,
      cursor: session.questionIds.length,
      completedAt: completedAt,
    );

    final entry = QuizHistoryEntry(
      sessionId: _session!.id,
      topic: _session!.topic,
      difficulty: _session!.difficulty,
      mode: _session!.mode,
      correct: _session!.correctCount,
      total: _session!.total,
      completedAt: completedAt,
    );
    _history = [entry, ..._history].take(50).toList();
    await _store.saveHistory(_history);
    await _store.saveActiveSession(_session);
    notifyListeners();
  }

  Future<void> clearActiveSession() async {
    _session = null;
    _pendingSelection = null;
    _revealed = false;
    await _store.saveActiveSession(null);
    notifyListeners();
  }

  Future<void> resumeOrDiscardCompleted() async {
    final session = _session;
    if (session == null) return;
    if (session.isComplete) {
      await clearActiveSession();
    }
  }

  /// Pure helper for tests: grade without mutating state.
  static bool validateAnswer(QuizQuestion question, int selectedIndex) {
    return question.isCorrect(selectedIndex);
  }

  /// Pure helper for tests: score a finished answer list.
  static int scoreCorrect(List<QuizAnswerRecord> answers) {
    return answers.where((a) => a.correct).length;
  }
}
