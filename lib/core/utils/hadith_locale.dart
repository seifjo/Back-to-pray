import '../../data/hadith_categories.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hadith.dart';

/// Locale-aware Hadith presentation helpers.
///
/// When [english] is true, only English text is used.
/// When false, only Arabic text is used — no mixed-language UI.
/// Never invents titles, grades, narrators, or topics.
class HadithLocale {
  HadithLocale._();

  static String collectionName(HadithItem item, AppLocalizations l10n) {
    for (final collection in HadithCollections.available) {
      if (item.collection == collection.id ||
          item.id.startsWith('${collection.id}:')) {
        return l10n.tr(collection.nameKey);
      }
    }
    return l10n.isArabic ? 'حديث' : 'Hadith';
  }

  static String referenceLabel(HadithItem item, AppLocalizations l10n) {
    final name = collectionName(item, l10n);
    if (item.book != null && item.hadithInBook != null) {
      return l10n
          .tr('hadithBookRef')
          .replaceAll('{collection}', name)
          .replaceAll('{book}', '${item.book}')
          .replaceAll('{hadith}', '${item.hadithInBook}');
    }
    return l10n
        .tr('hadithNumberRef')
        .replaceAll('{collection}', name)
        .replaceAll('{number}', '${item.number}');
  }

  /// Primary hadith body for the active app language.
  static String body(HadithItem item, {required bool english}) {
    if (english) return item.english.trim();
    return item.arabic.trim();
  }

  static bool hasBody(HadithItem item, {required bool english}) =>
      body(item, english: english).isNotEmpty;

  /// Narrator is parsed from English wording; only show in English mode.
  static String? narrator(HadithItem item, {required bool english}) {
    if (!english) return null;
    return item.narrator;
  }

  /// Short heading derived from the hadith text itself (not a fabricated title).
  static String? heading(HadithItem item, {required bool english}) {
    var text = body(item, english: english);
    if (text.isEmpty) return null;
    if (english) {
      final narrated = RegExp(
        r'^Narrated\s+[^:]+:\s*',
        caseSensitive: false,
      ).firstMatch(text);
      if (narrated != null) {
        text = text.substring(narrated.end).trim();
      }
    }
    if (text.isEmpty) return null;
    final end = RegExp(r'[.!?؟\n]').firstMatch(text);
    var snippet = end == null ? text : text.substring(0, end.start).trim();
    if (snippet.isEmpty) snippet = text;
    const max = 90;
    if (snippet.length <= max) return snippet;
    return '${snippet.substring(0, max).trim()}…';
  }

  /// Card preview — slightly longer than heading, still from source text.
  static String? preview(
    HadithItem item, {
    required bool english,
    int maxLinesChars = 160,
  }) {
    final text = body(item, english: english);
    if (text.isEmpty) return null;
    if (text.length <= maxLinesChars) return text;
    return '${text.substring(0, maxLinesChars).trim()}…';
  }

  static String? primaryGradeLabel(
    HadithItem item,
    AppLocalizations l10n,
  ) {
    if (!item.hasGrades) return null;
    for (final grade in item.grades) {
      if (grade.grade.trim().isEmpty) continue;
      return gradeLabel(grade.grade, l10n);
    }
    return null;
  }

  static HadithCategoryDef? topic(HadithItem item) =>
      HadithCategories.primaryFor(item);

  static String? topicLabel(HadithItem item, AppLocalizations l10n) {
    final category = topic(item);
    if (category == null) return null;
    return l10n.tr(category.nameKey);
  }

  static String gradeLabel(String raw, AppLocalizations l10n) {
    final lower = raw.toLowerCase();
    if (lower.contains('sahih') || lower.contains('صحيح')) {
      return l10n.tr('hadithGradeSahih');
    }
    if (lower.contains('hasan') || lower.contains('حسن')) {
      return l10n.tr('hadithGradeHasan');
    }
    if (lower.contains('daif') ||
        lower.contains('daʻif') ||
        lower.contains('da\'if') ||
        lower.contains('weak') ||
        lower.contains('ضعيف')) {
      return l10n.tr('hadithGradeDaif');
    }
    return raw;
  }

  static String attribution(AppLocalizations l10n) =>
      l10n.tr('hadithAttribution');

  static String shareText(
    HadithItem item,
    AppLocalizations l10n, {
    required bool english,
  }) {
    return [
      body(item, english: english),
      referenceLabel(item, l10n),
      attribution(l10n),
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
  }
}
