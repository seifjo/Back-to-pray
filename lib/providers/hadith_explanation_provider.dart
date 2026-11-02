import 'package:flutter/foundation.dart';

import '../core/services/hadith_explanation_service.dart';
import '../models/hadith_explanation.dart';

class HadithExplanationProvider extends ChangeNotifier {
  HadithExplanationProvider({HadithExplanationService? service})
      : _service = service ?? HadithExplanationService();

  final HadithExplanationService _service;
  bool _loading = true;
  String? _error;
  Set<String> _bookmarks = {};

  bool get loading => _loading;
  String? get error => _error;
  String get limitation => _service.limitation;
  List<String> get supportedIds => _service.supportedIds;
  Set<String> get bookmarks => _bookmarks;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.initialize();
      _bookmarks = await _service.loadBookmarks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool hasExplanation(String hadithId) => _service.hasExplanation(hadithId);

  HadithExplanation forHadith(String hadithId) =>
      _service.forHadith(hadithId);

  String? previousId(String hadithId) => _service.previousId(hadithId);

  String? nextId(String hadithId) => _service.nextId(hadithId);

  bool isBookmarked(String hadithId) => _bookmarks.contains(hadithId);

  Future<void> toggleBookmark(String hadithId) async {
    if (!_bookmarks.add(hadithId)) {
      _bookmarks.remove(hadithId);
    }
    await _service.saveBookmarks(_bookmarks);
    notifyListeners();
  }
}
