import '../models/adhkar.dart';
import '../models/dua.dart';
import 'adhkar_library.dart';

/// Verified dua catalog for Al Noor.
///
/// Content rules:
/// - Quranic entries quote the Arabic with surah:ayah references.
/// - Prophetic entries use wordings already present in the Adhkar library
///   or other widely reported Sahih/Sunan wordings cited beside each item.
/// - Shared Adhkar records are reused via [DuaItem.sharedAdhkarKey]
///   (`adhkarCategoryId::adhkarItemId`) instead of copying text twice.
/// - No invented references or fabricated Arabic.
class DuaLibrary {
  DuaLibrary._();

  static const attributionEn =
      'Quranic Arabic is quoted with surah and ayah. Prophetic wordings reuse '
      'the app Adhkar library or cite Bukhari, Muslim, Abu Dawud, or Tirmidhi. '
      'Translations are for understanding; verify with a trusted mushaf or scholar.';

  static const attributionAr =
      'النص القرآني يُنقل مع رقم السورة والآية. الأدعية النبوية تُعاد من مكتبة '
      'الأذكار أو تُسند إلى البخاري أو مسلم أو أبي داود أو الترمذي. الترجمات '
      'للتقريب؛ راجع مصحفاً أو عالماً موثوقاً.';

  static const categories = <DuaCategoryMeta>[
    DuaCategoryMeta(
      id: 'quranic',
      nameEn: 'Quranic Duas',
      nameAr: 'أدعية قرآنية',
      descriptionEn: 'Supplications in the words of the Quran',
      descriptionAr: 'أدعية بألفاظ القرآن الكريم',
    ),
    DuaCategoryMeta(
      id: 'prophetic',
      nameEn: 'Prophetic Supplications',
      nameAr: 'أدعية نبوية',
      descriptionEn: 'Supplications reported from the Prophet ﷺ',
      descriptionAr: 'أدعية ثابتة عن النبي ﷺ',
    ),
    DuaCategoryMeta(
      id: 'forgiveness',
      nameEn: 'Forgiveness and Repentance',
      nameAr: 'الاستغفار والتوبة',
      descriptionEn: 'Seeking forgiveness and returning to Allah',
      descriptionAr: 'طلب المغفرة والتوبة إلى الله',
    ),
    DuaCategoryMeta(
      id: 'guidance',
      nameEn: 'Guidance',
      nameAr: 'الهداية',
      descriptionEn: 'Asking Allah for guidance and steadfastness',
      descriptionAr: 'سؤال الله الهداية والثبات',
    ),
    DuaCategoryMeta(
      id: 'patience_gratitude',
      nameEn: 'Patience and Gratitude',
      nameAr: 'الصبر والشكر',
      descriptionEn: 'Duas for patience, firmness, and gratitude',
      descriptionAr: 'أدعية الصبر والثبات والشكر',
    ),
    DuaCategoryMeta(
      id: 'family',
      nameEn: 'Family',
      nameAr: 'الأهل والأسرة',
      descriptionEn: 'Supplications for parents, spouses, and children',
      descriptionAr: 'أدعية للوالدين والأزواج والذرية',
    ),
    DuaCategoryMeta(
      id: 'travel',
      nameEn: 'Travel',
      nameAr: 'السفر',
      descriptionEn: 'Supplication when setting out on a journey',
      descriptionAr: 'دعاء السفر وركوب الدابة',
    ),
    DuaCategoryMeta(
      id: 'difficult_times',
      nameEn: 'Difficult Times',
      nameAr: 'الهم والكرب',
      descriptionEn: 'Supplications in worry, grief, and hardship',
      descriptionAr: 'أدعية الهم والحزن والكرب',
    ),
    DuaCategoryMeta(
      id: 'daily',
      nameEn: 'Daily Duas',
      nameAr: 'أدعية يومية',
      descriptionEn: 'Home, food, and everyday moments',
      descriptionAr: 'أدعية المنزل والطعام ومواقف اليوم',
    ),
    DuaCategoryMeta(
      id: 'weather',
      nameEn: 'Rain and Weather',
      nameAr: 'المطر والريح',
      descriptionEn: 'Remembrances related to rain',
      descriptionAr: 'أذكار المطر وما يتعلق بالجو',
    ),
  ];

  static final List<DuaItem> all = List.unmodifiable(_buildAll());

  static DuaCategoryMeta? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static DuaItem? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<DuaItem> byCategory(String categoryId) {
    return all.where((item) => item.categoryId == categoryId).toList();
  }

  static List<DuaItem> search({
    String query = '',
    String? categoryId,
    bool favoritesOnly = false,
    Set<String> favoriteIds = const {},
  }) {
    final trimmed = query.trim().toLowerCase();
    return [
      for (final item in all)
        if ((!favoritesOnly || favoriteIds.contains(item.id)) &&
            (categoryId == null || item.categoryId == categoryId) &&
            (trimmed.isEmpty || _matches(item, trimmed)))
          item,
    ];
  }

  static List<DuaItem> related(DuaItem item, {int limit = 6}) {
    final sameCategory = <DuaItem>[];
    final sameSource = <DuaItem>[];
    for (final other in all) {
      if (other.id == item.id) continue;
      if (other.categoryId == item.categoryId) {
        sameCategory.add(other);
      } else if (other.sourceType == item.sourceType) {
        sameSource.add(other);
      }
    }
    return [...sameCategory, ...sameSource].take(limit).toList();
  }

  static AdhkarItem? sharedAdhkar(DuaItem item) {
    final key = item.sharedAdhkarKey;
    if (key == null) return null;
    final parts = key.split('::');
    if (parts.length != 2) return null;
    final category = AdhkarLibrary.byId(parts[0]);
    if (category == null) return null;
    for (final adhkar in category.items) {
      if (adhkar.id == parts[1]) return adhkar;
    }
    return null;
  }

  static bool _matches(DuaItem item, String query) {
    final haystack = [
      item.arabic,
      item.translationEn,
      item.translationAr,
      item.reference,
      item.explanationEn ?? '',
      item.explanationAr ?? '',
      item.id,
      item.categoryId,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  static List<DuaItem> _buildAll() {
    return [
      // —— Quranic (reuse Adhkar + extras) ——
      _fromAdhkar(
        duaId: 'quran-hearts',
        categoryId: 'quranic',
        adhkarCategoryId: 'quranic_duas',
        itemId: 'quran-hearts',
        sourceType: DuaSourceType.quranic,
      ),
      _fromAdhkar(
        duaId: 'quran-chest',
        categoryId: 'quranic',
        adhkarCategoryId: 'quranic_duas',
        itemId: 'quran-chest',
        sourceType: DuaSourceType.quranic,
      ),
      _fromAdhkar(
        duaId: 'rabbana-atina',
        categoryId: 'quranic',
        adhkarCategoryId: 'daily_duas',
        itemId: 'rabbana-atina',
        sourceType: DuaSourceType.quranic,
      ),

      // —— Prophetic ——
      _fromAdhkar(
        duaId: 'salawat',
        categoryId: 'prophetic',
        adhkarCategoryId: 'prophetic',
        itemId: 'salawat',
        sourceType: DuaSourceType.prophetic,
      ),
      const DuaItem(
        id: 'huda-taqwa',
        categoryId: 'prophetic',
        arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
        translationEn:
            'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
        translationAr: 'اللهم إني أسألك الهدى والتقى والعفاف والغنى.',
        reference: 'صحيح مسلم',
        explanationEn:
            'Reported from Abdullah ibn Masud. Listed among concise prophetic duas.',
        explanationAr: 'عن عبد الله بن مسعود رضي الله عنه في صحيح مسلم.',
        sourceType: DuaSourceType.prophetic,
      ),
      const DuaItem(
        id: 'muqallib-quloob',
        categoryId: 'prophetic',
        arabic: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
        translationEn:
            'O Turner of the hearts, keep my heart firm upon Your religion.',
        translationAr: 'يا مقلب القلوب ثبت قلبي على دينك.',
        reference: 'سنن الترمذي',
        explanationEn:
            'Widely reported prophetic wording asking Allah to keep the heart firm.',
        explanationAr: 'دعاء نبوي مشهور في سؤال الثبات على الدين.',
        sourceType: DuaSourceType.prophetic,
      ),

      // —— Forgiveness ——
      _fromAdhkar(
        duaId: 'sayyid-istighfar',
        categoryId: 'forgiveness',
        adhkarCategoryId: 'forgiveness',
        itemId: 'sayyid-istighfar',
        sourceType: DuaSourceType.prophetic,
        translationEn:
            'O Allah, You are my Lord, there is no deity except You. You created me and I am Your servant. I am upon Your covenant and promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me, and I acknowledge my sin, so forgive me, for none forgives sins except You.',
      ),
      _fromAdhkar(
        duaId: 'astaghfirullah',
        categoryId: 'forgiveness',
        adhkarCategoryId: 'forgiveness',
        itemId: 'astaghfirullah',
        sourceType: DuaSourceType.prophetic,
      ),

      // —— Guidance ——
      const DuaItem(
        id: 'fatiha-ihdina',
        categoryId: 'guidance',
        arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        translationEn: 'Guide us to the straight path.',
        translationAr: 'اهدنا الصراط المستقيم.',
        reference: 'الفاتحة: 6',
        explanationEn:
            'Recited in every unit of prayer. A Quranic request for guidance.',
        explanationAr: 'تُقرأ في كل ركعة؛ سؤال الهداية من ألفاظ القرآن.',
        sourceType: DuaSourceType.quranic,
      ),
      _fromAdhkar(
        duaId: 'rabbi-zidni',
        categoryId: 'guidance',
        adhkarCategoryId: 'daily_duas',
        itemId: 'rabbi-zidni',
        sourceType: DuaSourceType.quranic,
      ),
      // Also surface hearts / prophetic guidance as related via category links.

      // —— Patience and gratitude ——
      const DuaItem(
        id: 'baqarah-patience',
        categoryId: 'patience_gratitude',
        arabic:
            'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
        translationEn:
            'Our Lord, pour upon us patience, plant firmly our feet, and give us victory over the disbelieving people.',
        translationAr:
            'ربنا أفرغ علينا صبراً وثبت أقدامنا وانصرنا على القوم الكافرين.',
        reference: 'البقرة: 250',
        sourceType: DuaSourceType.quranic,
      ),
      const DuaItem(
        id: 'naml-gratitude',
        categoryId: 'patience_gratitude',
        arabic:
            'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَدْخِلْنِي بِرَحْمَتِكَ فِي عِبَادِكَ الصَّالِحِينَ',
        translationEn:
            'My Lord, enable me to be grateful for Your favor which You have bestowed upon me and upon my parents, and to do righteousness that You approve, and admit me by Your mercy into the company of Your righteous servants.',
        translationAr:
            'رب أوزعني أن أشكر نعمتك التي أنعمت علي وعلى والدي وأن أعمل صالحاً ترضاه وأدخلني برحمتك في عبادك الصالحين.',
        reference: 'النمل: 19',
        sourceType: DuaSourceType.quranic,
      ),

      // —— Family ——
      const DuaItem(
        id: 'furqan-family',
        categoryId: 'family',
        arabic:
            'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
        translationEn:
            'Our Lord, grant us from our spouses and offspring comfort to our eyes, and make us leaders for the righteous.',
        translationAr:
            'ربنا هب لنا من أزواجنا وذرياتنا قرة أعين واجعلنا للمتقين إماماً.',
        reference: 'الفرقان: 74',
        sourceType: DuaSourceType.quranic,
      ),
      const DuaItem(
        id: 'nuh-parents',
        categoryId: 'family',
        arabic:
            'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَن دَخَلَ بَيْتِيَ مُؤْمِنًا وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ',
        translationEn:
            'My Lord, forgive me and my parents and whoever enters my house as a believer, and the believing men and believing women.',
        translationAr:
            'رب اغفر لي ولوالدي ولمن دخل بيتي مؤمناً وللمؤمنين والمؤمنات.',
        reference: 'نوح: 28',
        sourceType: DuaSourceType.quranic,
      ),

      // —— Travel ——
      _fromAdhkar(
        duaId: 'travel-riding',
        categoryId: 'travel',
        adhkarCategoryId: 'travel',
        itemId: 'travel-riding',
        sourceType: DuaSourceType.prophetic,
      ),

      // —— Difficult times ——
      _fromAdhkar(
        duaId: 'anxiety-hamm',
        categoryId: 'difficult_times',
        adhkarCategoryId: 'anxiety',
        itemId: 'anxiety-hamm',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'anxiety-yunus',
        categoryId: 'difficult_times',
        adhkarCategoryId: 'anxiety',
        itemId: 'anxiety-yunus',
        sourceType: DuaSourceType.quranic,
      ),
      _fromAdhkar(
        duaId: 'hasbunallah',
        categoryId: 'difficult_times',
        adhkarCategoryId: 'prophetic',
        itemId: 'hasbunallah',
        sourceType: DuaSourceType.quranic,
      ),

      // —— Daily (home / food) ——
      _fromAdhkar(
        duaId: 'home-in',
        categoryId: 'daily',
        adhkarCategoryId: 'enter_home',
        itemId: 'home-in',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'home-out',
        categoryId: 'daily',
        adhkarCategoryId: 'leave_home',
        itemId: 'home-out',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'eat-bismillah',
        categoryId: 'daily',
        adhkarCategoryId: 'before_eating',
        itemId: 'eat-bismillah',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'eat-forgot',
        categoryId: 'daily',
        adhkarCategoryId: 'before_eating',
        itemId: 'eat-forgot',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'ate-hamd',
        categoryId: 'daily',
        adhkarCategoryId: 'after_eating',
        itemId: 'ate-hamd',
        sourceType: DuaSourceType.prophetic,
      ),

      // —— Weather ——
      _fromAdhkar(
        duaId: 'rain-sayyiban',
        categoryId: 'weather',
        adhkarCategoryId: 'weather',
        itemId: 'rain-sayyiban',
        sourceType: DuaSourceType.prophetic,
      ),
      _fromAdhkar(
        duaId: 'rain-fadl',
        categoryId: 'weather',
        adhkarCategoryId: 'weather',
        itemId: 'rain-fadl',
        sourceType: DuaSourceType.prophetic,
      ),
    ];
  }

  static DuaItem _fromAdhkar({
    required String duaId,
    required String categoryId,
    required String adhkarCategoryId,
    required String itemId,
    required DuaSourceType sourceType,
    String? translationEn,
  }) {
    final category = AdhkarLibrary.byId(adhkarCategoryId);
    if (category == null) {
      throw StateError('Missing Adhkar category: $adhkarCategoryId');
    }
    AdhkarItem? found;
    for (final item in category.items) {
      if (item.id == itemId) {
        found = item;
        break;
      }
    }
    if (found == null) {
      throw StateError('Missing Adhkar item: $adhkarCategoryId::$itemId');
    }
    final explanation = found.explanation;
    return DuaItem(
      id: duaId,
      categoryId: categoryId,
      arabic: found.arabicText,
      translationEn: translationEn ?? found.translation,
      translationAr: '',
      reference: found.reference,
      explanationEn: null,
      explanationAr: explanation,
      sourceType: sourceType,
      sharedAdhkarKey: '$adhkarCategoryId::$itemId',
    );
  }
}
