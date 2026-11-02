import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/islamic_quiz.dart';

/// Local persistence for quiz sessions and personal learning history.
class IslamicQuizStore {
  static const _activeSessionKey = 'islamic_quiz_active_session_v1';
  static const _historyKey = 'islamic_quiz_history_v1';
  static const _incorrectKey = 'islamic_quiz_incorrect_ids_v1';
  static const _correctKey = 'islamic_quiz_correct_ids_v1';
  static const _topicsKey = 'islamic_quiz_topics_reviewed_v1';
  static const _lifetimeCorrectKey = 'islamic_quiz_lifetime_correct_v1';
  static const _lifetimeAnsweredKey = 'islamic_quiz_lifetime_answered_v1';

  Future<QuizSession?> loadActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeSessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return QuizSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveSession(QuizSession? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_activeSessionKey);
      return;
    }
    await prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
  }

  Future<List<QuizHistoryEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => QuizHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveHistory(List<QuizHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<Set<String>> loadIncorrectIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_incorrectKey)?.toSet() ?? {};
  }

  Future<void> saveIncorrectIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_incorrectKey, ids.toList());
  }

  Future<Set<String>> loadCorrectIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_correctKey)?.toSet() ?? {};
  }

  Future<void> saveCorrectIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_correctKey, ids.toList());
  }

  Future<Set<String>> loadTopicsReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_topicsKey)?.toSet() ?? {};
  }

  Future<void> saveTopicsReviewed(Set<String> topics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_topicsKey, topics.toList());
  }

  Future<int> loadLifetimeCorrect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lifetimeCorrectKey) ?? 0;
  }

  Future<int> loadLifetimeAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lifetimeAnsweredKey) ?? 0;
  }

  Future<void> saveLifetime({
    required int correct,
    required int answered,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lifetimeCorrectKey, correct);
    await prefs.setInt(_lifetimeAnsweredKey, answered);
  }
}
