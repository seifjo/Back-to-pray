import 'package:flutter/foundation.dart';

import '../core/services/asma_preferences_store.dart';
import '../data/asma_ul_husna.dart';
import '../models/asma.dart';

class AsmaProvider extends ChangeNotifier {
  AsmaProvider({AsmaPreferencesStore? store})
      : _store = store ?? AsmaPreferencesStore();

  final AsmaPreferencesStore _store;

  bool _loading = true;
  String? _error;
  String _query = '';
  String? _themeFilter;
  AsmaSourceKind? _sourceFilter;
  AsmaCollectionKind? _collectionFilter;
  bool _favoritesOnly = false;
  Set<String> _favorites = {};
  Set<String> _reviewed = {};
  AsmaLearningSession? _session;
  int _lifetimeQuizCorrect = 0;
  int _lifetimeQuizAnswered = 0;
  bool _meaningRevealed = false;
  List<String> _currentQuizOptions = const [];

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  String? get themeFilter => _themeFilter;
  AsmaSourceKind? get sourceFilter => _sourceFilter;
  AsmaCollectionKind? get collectionFilter => _collectionFilter;
  bool get favoritesOnly => _favoritesOnly;
  Set<String> get favorites => _favorites;
  Set<String> get reviewed => _reviewed;
  AsmaLearningSession? get session => _session;
  bool get meaningRevealed => _meaningRevealed;
  List<String> get currentQuizOptions => _currentQuizOptions;
  int get lifetimeQuizCorrect => _lifetimeQuizCorrect;
  int get lifetimeQuizAnswered => _lifetimeQuizAnswered;
  String get attributionEn => AsmaUlHusna.attributionEn;
  String get attributionAr => AsmaUlHusna.attributionAr;
  String get sourceUrl => AsmaUlHusna.sourceUrl;
  String get artworkAsset => AsmaUlHusna.artworkAsset;
  List<AsmaTheme> get themes => AsmaUlHusna.themes;

  int get reviewedCount =>
      _reviewed.where((id) => AsmaUlHusna.byId(id)?.isPrimary ?? false).length;
  /// Learning progress is tracked against the primary 1–99 ranking.
  int get totalCount => AsmaUlHusna.primary.length;
  int get catalogCount => AsmaUlHusna.all.length;
  double get learningProgress =>
      totalCount == 0 ? 0 : reviewedCount / totalCount;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (AsmaUlHusna.primary.length != 99) {
        throw StateError(
          'Expected 99 primary names, found ${AsmaUlHusna.primary.length}',
        );
      }
      if (AsmaUlHusna.primary.first.arabic != 'الله') {
        throw StateError('Primary ranking must begin with الله');
      }
      _favorites = await _store.loadFavorites();
      _reviewed = await _store.loadReviewed();
      _session = await _store.loadSession();
      _lifetimeQuizCorrect = await _store.loadLifetimeQuizCorrect();
      _lifetimeQuizAnswered = await _store.loadLifetimeQuizAnswered();
      _prepareCardState();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<DivineName> get filtered {
    return AsmaUlHusna.search(
      query: _query,
      themeId: _themeFilter,
      sourceKind: _sourceFilter,
      collection: _collectionFilter,
      favoritesOnly: _favoritesOnly,
      favoriteIds: _favorites,
    );
  }

  List<DivineName> get favoriteNames {
    final favorites = [
      for (final name in AsmaUlHusna.all)
        if (_favorites.contains(name.id)) name,
    ];
    return favorites;
  }

  DivineName? byId(String id) => AsmaUlHusna.byId(id);

  List<DivineName> related(DivineName name) => AsmaUlHusna.related(name);

  bool isFavorite(String id) => _favorites.contains(id);

  bool isReviewed(String id) => _reviewed.contains(id);

  DivineName? get currentLearningName {
    final session = _session;
    if (session == null || session.isComplete) return null;
    return AsmaUlHusna.byId(session.nameIds[session.cursor]);
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setThemeFilter(String? value) {
    _themeFilter = value;
    _favoritesOnly = false;
    notifyListeners();
  }

  void setSourceFilter(AsmaSourceKind? value) {
    _sourceFilter = value;
    notifyListeners();
  }

  void setCollectionFilter(AsmaCollectionKind? value) {
    _collectionFilter = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    if (value) _themeFilter = null;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _themeFilter = null;
    _sourceFilter = null;
    _collectionFilter = null;
    _favoritesOnly = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favorites.contains(id)) {
      _favorites = {..._favorites}..remove(id);
    } else {
      _favorites = {..._favorites, id};
    }
    notifyListeners();
    await _store.saveFavorites(_favorites);
  }

  Future<void> markReviewed(String id) async {
    _reviewed = {..._reviewed, id};
    notifyListeners();
    await _store.saveReviewed(_reviewed);
  }

  Future<void> clearReviewedProgress() async {
    _reviewed = {};
    notifyListeners();
    await _store.saveReviewed(_reviewed);
  }

  Future<void> startSession({
    int size = 10,
    bool quizMode = false,
    bool unreviewedOnly = true,
  }) async {
    // Learning sessions follow the primary 1–99 ranking only.
    var pool = [
      for (final name in AsmaUlHusna.primary)
        if (!unreviewedOnly || !_reviewed.contains(name.id)) name.id,
    ];
    if (pool.isEmpty) {
      pool = AsmaUlHusna.primary.map((name) => name.id).toList();
    }
    final selected = pool.take(size.clamp(1, pool.length)).toList();
    _session = AsmaLearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameIds: selected,
      cursor: 0,
      quizMode: quizMode,
      quizCorrect: 0,
      quizAnswered: 0,
      startedAt: DateTime.now(),
    );
    _prepareCardState();
    notifyListeners();
    await _store.saveSession(_session);
  }

  Future<void> restartSession() async {
    final session = _session;
    if (session == null) {
      await startSession();
      return;
    }
    await startSession(
      size: session.nameIds.length,
      quizMode: session.quizMode,
      unreviewedOnly: false,
    );
  }

  void revealMeaning() {
    _meaningRevealed = true;
    notifyListeners();
  }

  Future<void> markCurrentReviewedAndNext() async {
    final current = currentLearningName;
    if (current == null || _session == null) return;
    await markReviewed(current.id);
    final nextCursor = _session!.cursor + 1;
    _session = _session!.copyWith(cursor: nextCursor);
    _prepareCardState();
    notifyListeners();
    await _store.saveSession(_session);
  }

  Future<void> skipToNext() async {
    if (_session == null || _session!.isComplete) return;
    _session = _session!.copyWith(cursor: _session!.cursor + 1);
    _prepareCardState();
    notifyListeners();
    await _store.saveSession(_session);
  }

  Future<bool> answerQuiz(String selectedMeaning) async {
    final current = currentLearningName;
    final session = _session;
    if (current == null || session == null || !session.quizMode) {
      return false;
    }
    final correct = selectedMeaning == current.meaningEn;
    final quizCorrect = session.quizCorrect + (correct ? 1 : 0);
    final quizAnswered = session.quizAnswered + 1;
    _session = session.copyWith(
      quizCorrect: quizCorrect,
      quizAnswered: quizAnswered,
      cursor: session.cursor + 1,
    );
    if (correct) {
      await markReviewed(current.id);
    }
    _lifetimeQuizCorrect += correct ? 1 : 0;
    _lifetimeQuizAnswered += 1;
    _prepareCardState();
    notifyListeners();
    await _store.saveSession(_session);
    await _store.saveLifetimeQuiz(
      correct: _lifetimeQuizCorrect,
      answered: _lifetimeQuizAnswered,
    );
    return correct;
  }

  Future<void> endSession() async {
    _session = null;
    _meaningRevealed = false;
    _currentQuizOptions = const [];
    notifyListeners();
    await _store.saveSession(null);
  }

  void _prepareCardState() {
    _meaningRevealed = false;
    final current = currentLearningName;
    final session = _session;
    if (current != null && session != null && session.quizMode) {
      _currentQuizOptions = AsmaUlHusna.quizOptions(current);
    } else {
      _currentQuizOptions = const [];
    }
  }
}
