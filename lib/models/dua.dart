enum DuaSourceType {
  quranic,
  prophetic,
}

class DuaItem {
  final String id;
  final String categoryId;
  final String arabic;
  final String translationEn;
  final String translationAr;
  final String reference;
  final String? explanationEn;
  final String? explanationAr;
  final DuaSourceType sourceType;
  /// When set, reuses Adhkar content keyed as `categoryId::itemId`.
  final String? sharedAdhkarKey;

  const DuaItem({
    required this.id,
    required this.categoryId,
    required this.arabic,
    required this.translationEn,
    this.translationAr = '',
    required this.reference,
    this.explanationEn,
    this.explanationAr,
    required this.sourceType,
    this.sharedAdhkarKey,
  });

  String translation(bool english) =>
      english || translationAr.isEmpty ? translationEn : translationAr;

  String? explanation(bool english) {
    if (english) {
      return explanationEn?.isNotEmpty == true
          ? explanationEn
          : explanationAr;
    }
    return explanationAr?.isNotEmpty == true ? explanationAr : explanationEn;
  }

  bool get isQuranic => sourceType == DuaSourceType.quranic;
}

class DuaCategoryMeta {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;

  const DuaCategoryMeta({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
  });

  String name(bool english) => english ? nameEn : nameAr;

  String description(bool english) => english ? descriptionEn : descriptionAr;
}
