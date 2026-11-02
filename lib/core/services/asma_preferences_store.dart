import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/asma.dart';

/// Persistent favorites, reviewed names, and learning session state.
class AsmaPreferencesStore {
  static const _favoritesKey = 'asma_favorites_v1';
  static const _reviewedKey = 'asma_reviewed_v1';
  static const _sessionKey = 'asma_session_v1';
  static const _quizCorrectKey = 'asma_quiz_correct_v1';
  static const _quizAnsweredKey = 'asma_quiz_answered_v1';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey)?.toSet() ?? {};
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }

  Future<Set<String>> loadReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_reviewedKey)?.toSet() ?? {};
  }

  Future<void> saveReviewed(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_reviewedKey, ids.toList());
  }

  Future<AsmaLearningSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AsmaLearningSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(AsmaLearningSession? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_sessionKey);
      return;
    }
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<int> loadLifetimeQuizCorrect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizCorrectKey) ?? 0;
  }

  Future<int> loadLifetimeQuizAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizAnsweredKey) ?? 0;
  }

  Future<void> saveLifetimeQuiz({
    required int correct,
    required int answered,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_quizCorrectKey, correct);
    await prefs.setInt(_quizAnsweredKey, answered);
  }
}
