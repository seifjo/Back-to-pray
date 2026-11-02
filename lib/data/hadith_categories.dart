import '../models/hadith.dart';

/// Theme filters mapped to keyword search over verified English text.
/// Categories never invent Hadith; they only filter real translations / seed tags.
class HadithCategoryDef {
  final String id;
  final String nameKey;
  final List<String> keywords;
  final String? seedId;

  const HadithCategoryDef({
    required this.id,
    required this.nameKey,
    required this.keywords,
    this.seedId,
  });
}

class HadithCategories {
  static const all = <HadithCategoryDef>[
    HadithCategoryDef(
      id: 'prayer',
      nameKey: 'hadithCatPrayer',
      keywords: ['prayer', 'salat', 'pray', 'salah'],
      seedId: 'prayer',
    ),
    HadithCategoryDef(
      id: 'faith',
      nameKey: 'hadithCatFaith',
      keywords: ['faith', 'belief', 'iman'],
      seedId: 'faith',
    ),
    HadithCategoryDef(
      id: 'patience',
      nameKey: 'hadithCatPatience',
      keywords: ['patience', 'patient', 'sabr'],
      seedId: 'patience',
    ),
    HadithCategoryDef(
      id: 'gratitude',
      nameKey: 'hadithCatGratitude',
      keywords: ['thank', 'gratitude', 'grateful'],
      seedId: 'gratitude',
    ),
    HadithCategoryDef(
      id: 'character',
      nameKey: 'hadithCatCharacter',
      keywords: ['character', 'manners', 'neighbor', 'truthful', 'honesty'],
      seedId: 'character',
    ),
    HadithCategoryDef(
      id: 'knowledge',
      nameKey: 'hadithCatKnowledge',
      keywords: ['knowledge', 'learn', 'scholar'],
      seedId: 'knowledge',
    ),
    HadithCategoryDef(
      id: 'mercy',
      nameKey: 'hadithCatMercy',
      keywords: ['mercy', 'merciful', 'compassion', 'kind'],
      seedId: 'mercy',
    ),
    HadithCategoryDef(
      id: 'family',
      nameKey: 'hadithCatFamily',
      keywords: ['family', 'mother', 'father', 'parent', 'wife', 'husband', 'child'],
      seedId: 'family',
    ),
    HadithCategoryDef(
      id: 'fasting',
      nameKey: 'hadithCatFasting',
      keywords: ['fast', 'ramadan', 'saum'],
      seedId: 'fasting',
    ),
    HadithCategoryDef(
      id: 'charity',
      nameKey: 'hadithCatCharity',
      keywords: ['charity', 'sadaqa', 'sadaqah', 'zakat', 'spend'],
      seedId: 'charity',
    ),
    HadithCategoryDef(
      id: 'repentance',
      nameKey: 'hadithCatRepentance',
      keywords: ['repent', 'forgiveness', 'forgive', 'tawba'],
      seedId: 'repentance',
    ),
    HadithCategoryDef(
      id: 'dhikr',
      nameKey: 'hadithCatDhikr',
      keywords: ['remembrance', 'dhikr', 'remember allah', 'glorify', 'tasbih'],
      seedId: 'dhikr',
    ),
  ];

  static HadithCategoryDef? byId(String id) {
    for (final category in all) {
      if (category.id == id) return category;
    }
    return null;
  }

  static bool matches(HadithItem item, HadithCategoryDef category) {
    if (item.seedCategory != null &&
        item.seedCategory == category.seedId) {
      return true;
    }
    final text = item.english.toLowerCase();
    if (text.isEmpty) return false;
    return category.keywords.any((keyword) => text.contains(keyword));
  }

  /// First matching topic supported by seed tags / English keywords.
  /// Returns null when nothing reliable matches — never invent a topic.
  static HadithCategoryDef? primaryFor(HadithItem item) {
    if (item.seedCategory != null && item.seedCategory!.isNotEmpty) {
      for (final category in all) {
        if (category.seedId == item.seedCategory) return category;
      }
    }
    for (final category in all) {
      final text = item.english.toLowerCase();
      if (text.isEmpty) continue;
      if (category.keywords.any((keyword) => text.contains(keyword))) {
        return category;
      }
    }
    return null;
  }

  static List<HadithCategoryDef> allMatching(HadithItem item) {
    return [for (final category in all) if (matches(item, category)) category];
  }
}

class HadithCollections {
  static const available = <HadithCollectionInfo>[
    HadithCollectionInfo(
      id: 'nawawi',
      nameKey: 'hadithColNawawi',
      engEdition: 'eng-nawawi',
      araEdition: 'ara-nawawi',
    ),
    HadithCollectionInfo(
      id: 'bukhari',
      nameKey: 'hadithColBukhari',
      engEdition: 'eng-bukhari',
      araEdition: 'ara-bukhari',
    ),
    HadithCollectionInfo(
      id: 'muslim',
      nameKey: 'hadithColMuslim',
      engEdition: 'eng-muslim',
      araEdition: 'ara-muslim',
    ),
    HadithCollectionInfo(
      id: 'abudawud',
      nameKey: 'hadithColAbuDawud',
      engEdition: 'eng-abudawud',
      araEdition: 'ara-abudawud',
      typicallyGraded: true,
    ),
  ];
}
