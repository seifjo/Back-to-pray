import '../models/adhkar.dart';
import 'adhkar_shared_catalog.dart';

/// Authentic remembrance library.
///
/// Quranic text is quoted with its surah and verse. Prophetic supplications
/// cite Bukhari, Muslim, or the Sunan named beside each item.
/// Shared dhikr is stored once in [AdhkarSharedCatalog] and placed by content id.
class AdhkarLibrary {
  /// Bumped when bundled Adhkar text/structure changes.
  static const int contentVersion = 3;

  // Local alias keeps category lists readable.
  // ignore: non_constant_identifier_names
  static AdhkarItem S(String contentId, {required String id}) =>
      AdhkarSharedCatalog.place(contentId, id: id);

  static List<AdhkarCategory> get categories => [
        morning,
        evening,
        afterPrayer,
        beforeSleep,
        uponWaking,
        enteringHome,
        leavingHome,
        enteringMosque,
        leavingMosque,
        beforeEating,
        afterEating,
        traveling,
        weather,
        forgiveness,
        repentance,
        generalDhikr,
        quranicDuas,
        prophetic,
        friday,
        protection,
        anxiety,
        gratitude,
        dailyDuas,
      ];

  static AdhkarCategory? byId(String id) {
    for (final category in categories) {
      if (category.stableId == id) return category;
    }
    return null;
  }

  static AdhkarItem? itemByContentId(String contentId) =>
      AdhkarSharedCatalog.byContentId(contentId);

  /// All unique content ids across the library (for dedupe checks).
  static Set<String> get allContentIds {
    final ids = <String>{};
    for (final category in categories) {
      for (final item in category.items) {
        ids.add(item.stableContentId);
      }
    }
    return ids;
  }

  static int get totalItemPlacements => categories.fold<int>(
        0,
        (sum, c) => sum + c.items.length,
      );

  // —— Categories ——

  static final morning = AdhkarCategory(
    id: 'morning',
    name: 'أذكار الصباح',
    nameEn: 'Morning Adhkar',
    description: 'الأذكار التي تُقال من بعد صلاة الفجر إلى طلوع الشمس',
    descriptionEn: 'Remembrances from Fajr until sunrise',
    recommendedTime: 'من بعد صلاة الفجر حتى طلوع الشمس',
    recommendedTimeEn: 'After Fajr until sunrise',
    icon: '🌅',
    items: [
      S('shared-ayat-kursi', id: 'morning-kursi'),
      S('shared-ikhlas', id: 'morning-ikhlas'),
      S('shared-falaq', id: 'morning-falaq'),
      S('shared-nas', id: 'morning-nas'),
      S('shared-asbahna', id: 'morning-asbahna'),
      S('shared-bika-asbahna', id: 'morning-bika'),
      S('shared-raditu', id: 'morning-raditu'),
      S('shared-hasbiyallah', id: 'morning-hasbiyallah'),
      S('shared-afiyah', id: 'morning-afiyah'),
      S('shared-bismillah-protect', id: 'morning-protect'),
      S('shared-sayyid-istighfar', id: 'morning-sayyid'),
      S('shared-subhan-bihamdihi', id: 'morning-subhan'),
      S('shared-tahlil', id: 'morning-tahlil'),
      S('shared-kalimat', id: 'morning-kalimat'),
    ],
  );

  static final evening = AdhkarCategory(
    id: 'evening',
    name: 'أذكار المساء',
    nameEn: 'Evening Adhkar',
    description: 'الأذكار التي تُقال من بعد صلاة العصر إلى غروب الشمس',
    descriptionEn: 'Remembrances from Asr until sunset',
    recommendedTime: 'من بعد صلاة العصر حتى غروب الشمس',
    recommendedTimeEn: 'After Asr until sunset',
    icon: '🌙',
    items: [
      S('shared-ayat-kursi', id: 'evening-kursi'),
      S('shared-ikhlas', id: 'evening-ikhlas'),
      S('shared-falaq', id: 'evening-falaq'),
      S('shared-nas', id: 'evening-nas'),
      S('shared-amsayna', id: 'evening-amsayna'),
      S('shared-bika-amsayna', id: 'evening-bika'),
      S('shared-kalimat', id: 'evening-kalimat'),
      S('shared-raditu', id: 'evening-raditu'),
      S('shared-hasbiyallah', id: 'evening-hasbiyallah'),
      S('shared-afiyah', id: 'evening-afiyah'),
      S('shared-bismillah-protect', id: 'evening-protect'),
      S('shared-sayyid-istighfar', id: 'evening-sayyid'),
      S('shared-subhan-bihamdihi', id: 'evening-subhan'),
      S('shared-tahlil', id: 'evening-tahlil'),
    ],
  );

  static final afterPrayer = AdhkarCategory(
    id: 'after_prayer',
    name: 'أذكار بعد الصلاة',
    nameEn: 'After Prayer',
    description: 'يُقال بعد السلام من الصلاة',
    descriptionEn: 'Said after the taslim',
    recommendedTime: 'بعد السلام',
    recommendedTimeEn: 'After the taslim',
    icon: '🕌',
    items: [
      const AdhkarItem(
        id: 'after-istighfar',
        contentId: 'after-istighfar',
        arabicText: 'أَسْتَغْفِرُ اللَّهَ',
        repetitions: 3,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        narrator: 'ثوبان رضي الله عنه',
        translation: 'I ask Allah for forgiveness.',
        explanation:
            'قال ثوبان رضي الله عنه إن النبي ﷺ كان إذا انصرف من صلاته استغفر ثلاثاً.',
      ),
      const AdhkarItem(
        id: 'after-salam',
        contentId: 'after-salam',
        arabicText:
            'اللَّهُمَّ أَنتَ السَّلَامُ وَمِنكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
        repetitions: 1,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation:
            'O Allah, You are Peace and from You is peace. Blessed are You, O Owner of majesty and honor.',
      ),
      const AdhkarItem(
        id: 'after-tahlil',
        contentId: 'after-tahlil',
        arabicText:
            'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنكَ الْجَدُّ',
        repetitions: 1,
        reference: 'صحيح البخاري ومسلم',
        sourceBook: 'صحيح البخاري ومسلم',
        authenticity: 'Sahih',
        translation:
            'None has the right to be worshipped except Allah, alone, without partner. To Him belongs dominion and praise, and He is over all things competent. O Allah, none can withhold what You give, and none can give what You withhold, and the might of the mighty is of no avail against You.',
      ),
      const AdhkarItem(
        id: 'after-tasbih',
        contentId: 'after-tasbih',
        arabicText: 'سُبْحَانَ اللَّهِ',
        repetitions: 33,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation: 'Glory be to Allah.',
        explanation: 'ثم الحمد لله ثلاثاً وثلاثين، والله أكبر ثلاثاً وثلاثين.',
      ),
      S('shared-alhamdulillah', id: 'after-hamd'),
      const AdhkarItem(
        id: 'after-takbir',
        contentId: 'after-takbir',
        arabicText: 'اللَّهُ أَكْبَرُ',
        repetitions: 33,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation: 'Allah is the Greatest.',
      ),
      S('shared-tahlil', id: 'after-complete-hundred').copyWith(repetitions: 1),
      S('shared-ayat-kursi', id: 'after-kursi'),
    ],
  );

  static final beforeSleep = AdhkarCategory(
    id: 'before_sleep',
    name: 'أذكار النوم',
    nameEn: 'Before Sleeping',
    description: 'ما يُقرأ عند النوم من القرآن والذكر',
    descriptionEn: 'Quran and remembrance at bedtime',
    recommendedTime: 'عند النوم',
    recommendedTimeEn: 'At bedtime',
    icon: '😴',
    items: [
      S('shared-sleep-bismika', id: 'sleep-bismika'),
      S('shared-ayat-kursi', id: 'sleep-kursi'),
      S('shared-baqarah-end', id: 'sleep-baqarah-end'),
      S('shared-ikhlas', id: 'sleep-ikhlas'),
      S('shared-falaq', id: 'sleep-falaq'),
      S('shared-nas', id: 'sleep-nas'),
      S('shared-sleep-hands', id: 'sleep-hands-dua'),
      S('shared-kalimat', id: 'sleep-kalimat'),
    ],
  );

  static final uponWaking = AdhkarCategory(
    id: 'waking',
    name: 'أذكار الاستيقاظ',
    nameEn: 'Upon Waking',
    description: 'دعاء الاستيقاظ من النوم',
    descriptionEn: 'Supplication when waking from sleep',
    recommendedTime: 'عند الاستيقاظ',
    recommendedTimeEn: 'When waking',
    icon: '🌤',
    items: [
      S('shared-waking-hamd', id: 'waking-hamd'),
      S('shared-waking-afiyah', id: 'waking-hamd-afiyah'),
      S('shared-alhamdulillah', id: 'waking-alhamd').copyWith(repetitions: 1),
    ],
  );

  static final enteringMosque = AdhkarCategory(
    id: 'enter_mosque',
    name: 'دخول المسجد',
    nameEn: 'Entering the Mosque',
    description: 'دعاء دخول المسجد',
    descriptionEn: 'When entering the mosque',
    recommendedTime: 'عند الدخول',
    recommendedTimeEn: 'On entering',
    icon: '🕋',
    items: [
      const AdhkarItem(
        id: 'mosque-in-istiadhah',
        contentId: 'mosque-in-istiadhah',
        arabicText:
            'أَعُوذُ بِاللَّهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ',
        repetitions: 1,
        reference: 'سنن أبي داود',
        sourceBook: 'سنن أبي داود',
        translation:
            'I seek refuge in Allah the Magnificent, and in His noble Face, and in His eternal dominion, from the accursed Satan.',
      ),
      const AdhkarItem(
        id: 'mosque-in',
        contentId: 'mosque-in',
        arabicText: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        repetitions: 1,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation: 'O Allah, open for me the gates of Your mercy.',
      ),
    ],
  );

  static final leavingMosque = AdhkarCategory(
    id: 'leave_mosque',
    name: 'الخروج من المسجد',
    nameEn: 'Leaving the Mosque',
    description: 'دعاء الخروج من المسجد',
    descriptionEn: 'When leaving the mosque',
    recommendedTime: 'عند الخروج',
    recommendedTimeEn: 'On leaving',
    icon: '🚶',
    items: [
      const AdhkarItem(
        id: 'mosque-out',
        contentId: 'mosque-out',
        arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِن فَضْلِكَ',
        repetitions: 1,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation: 'O Allah, I ask You from Your bounty.',
      ),
    ],
  );

  static final enteringHome = AdhkarCategory(
    id: 'enter_home',
    name: 'دخول المنزل',
    nameEn: 'Entering the Home',
    description: 'ذكر دخول البيت',
    descriptionEn: 'When entering the house',
    recommendedTime: 'عند الدخول',
    recommendedTimeEn: 'On entering',
    icon: '🏠',
    items: [
      const AdhkarItem(
        id: 'home-in',
        contentId: 'home-in',
        arabicText:
            'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا',
        repetitions: 1,
        reference: 'سنن أبي داود',
        sourceBook: 'سنن أبي داود',
        translation:
            'In the name of Allah we enter, in the name of Allah we leave, and upon Allah our Lord we rely.',
      ),
      S('shared-kalimat', id: 'home-in-kalimat'),
    ],
  );

  static final leavingHome = AdhkarCategory(
    id: 'leave_home',
    name: 'الخروج من المنزل',
    nameEn: 'Leaving the Home',
    description: 'ذكر الخروج من البيت',
    descriptionEn: 'When leaving the house',
    recommendedTime: 'عند الخروج',
    recommendedTimeEn: 'On leaving',
    icon: '🚪',
    items: [
      const AdhkarItem(
        id: 'home-out',
        contentId: 'home-out',
        arabicText:
            'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        repetitions: 1,
        reference: 'سنن أبي داود والترمذي',
        sourceBook: 'سنن أبي داود والترمذي',
        translation:
            'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
      ),
      S('shared-hawqalah', id: 'home-out-hawqalah'),
    ],
  );

  static final beforeEating = AdhkarCategory(
    id: 'before_eating',
    name: 'قبل الطعام',
    nameEn: 'Before Eating',
    description: 'التسمية عند الطعام',
    descriptionEn: 'Mentioning Allah before food',
    recommendedTime: 'قبل الأكل',
    recommendedTimeEn: 'Before eating',
    icon: '🍽',
    items: [
      const AdhkarItem(
        id: 'eat-bismillah',
        contentId: 'eat-bismillah',
        arabicText: 'بِسْمِ اللَّهِ',
        repetitions: 1,
        reference: 'صحيح البخاري',
        sourceBook: 'صحيح البخاري',
        authenticity: 'Sahih',
        translation: 'In the name of Allah.',
      ),
      const AdhkarItem(
        id: 'eat-forgot',
        contentId: 'eat-forgot',
        arabicText: 'بِسْمِ اللَّهِ أَوَّلَهُ وَآخِرَهُ',
        repetitions: 1,
        reference: 'سنن أبي داود والترمذي',
        sourceBook: 'سنن أبي داود والترمذي',
        translation: 'In the name of Allah at its beginning and at its end.',
        explanation: 'إذا نسي التسمية في أول الطعام.',
      ),
    ],
  );

  static final afterEating = AdhkarCategory(
    id: 'after_eating',
    name: 'بعد الطعام',
    nameEn: 'After Eating',
    description: 'حمد الله بعد الطعام',
    descriptionEn: 'Praising Allah after food',
    recommendedTime: 'بعد الأكل',
    recommendedTimeEn: 'After eating',
    icon: '🤲',
    items: [
      S('shared-ate-hamd', id: 'ate-hamd'),
      S('shared-alhamdulillah', id: 'ate-alhamd').copyWith(repetitions: 1),
    ],
  );

  static final traveling = AdhkarCategory(
    id: 'travel',
    name: 'أذكار السفر',
    nameEn: 'Travel',
    description: 'دعاء ركوب الدابة والسفر',
    descriptionEn: 'Supplication for travel',
    recommendedTime: 'عند السفر',
    recommendedTimeEn: 'When setting out',
    icon: '🛣',
    items: [
      const AdhkarItem(
        id: 'travel-riding',
        contentId: 'travel-riding',
        arabicText:
            'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ، اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الْأَهْلِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِن وَعْثَاءِ السَّفَرِ، وَكَآبَةِ الْمَنظَرِ، وَسُوءِ الْمُنقَلَبِ فِي الْمَالِ وَالْأَهْلِ',
        repetitions: 1,
        reference: 'صحيح مسلم، وفيه من سورة الزخرف: 13-14',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation:
            'Allah is the Greatest. Glory be to Him who has subjected this to us, and we could never have it by our efforts. Indeed, to our Lord we will return. O Allah, we ask You for righteousness and piety in this journey of ours, and for deeds that please You. O Allah, make this journey easy for us and fold up its distance. O Allah, You are the Companion on the journey and the Successor over the family. O Allah, I seek refuge in You from the hardships of travel, from a gloomy sight, and from an ill return in wealth and family.',
      ),
      const AdhkarItem(
        id: 'travel-return',
        contentId: 'travel-return',
        arabicText: 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
        repetitions: 1,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation:
            'We return, repentant, worshipping, and praising our Lord.',
        explanation: 'يُقال عند الرجوع من السفر كما في مسلم.',
      ),
      S('shared-hawqalah', id: 'travel-hawqalah'),
    ],
  );

  static final weather = AdhkarCategory(
    id: 'weather',
    name: 'أذكار المطر',
    nameEn: 'Rain',
    description: 'أذكار نزول المطر',
    descriptionEn: 'Remembrances related to rain',
    recommendedTime: 'عند نزول المطر',
    recommendedTimeEn: 'When rain falls',
    icon: '🌧',
    items: [
      const AdhkarItem(
        id: 'rain-sayyiban',
        contentId: 'rain-sayyiban',
        arabicText: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
        repetitions: 1,
        reference: 'صحيح البخاري',
        sourceBook: 'صحيح البخاري',
        authenticity: 'Sahih',
        translation: 'O Allah, a beneficial downpour.',
      ),
      const AdhkarItem(
        id: 'rain-fadl',
        contentId: 'rain-fadl',
        arabicText: 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
        repetitions: 1,
        reference: 'صحيح البخاري ومسلم',
        sourceBook: 'صحيح البخاري ومسلم',
        authenticity: 'Sahih',
        translation: 'We have been given rain by the grace and mercy of Allah.',
      ),
      const AdhkarItem(
        id: 'rain-around',
        contentId: 'rain-around',
        arabicText:
            'اللَّهُمَّ حَوَالَيْنَا وَلَا عَلَيْنَا، اللَّهُمَّ عَلَى الْآكَامِ وَالظِّرَابِ، وَبُطُونِ الْأَوْدِيَةِ، وَمَنَابِتِ الشَّجَرِ',
        repetitions: 1,
        reference: 'صحيح البخاري ومسلم',
        sourceBook: 'صحيح البخاري ومسلم',
        authenticity: 'Sahih',
        translation:
            'O Allah, around us and not upon us. O Allah, upon the hills, the small mountains, the bottoms of the valleys, and the places where trees grow.',
        explanation: 'يُقال إذا كثر المطر وخُشي الضرر، كما في الصحيحين.',
      ),
    ],
  );

  static final forgiveness = AdhkarCategory(
    id: 'forgiveness',
    name: 'الاستغفار',
    nameEn: 'Seeking Forgiveness',
    description: 'سيد الاستغفار وما يقاربه',
    descriptionEn: 'Seeking Allah’s forgiveness',
    recommendedTime: 'في الصباح والمساء وبعد الذنب',
    recommendedTimeEn: 'Morning, evening, and after a sin',
    icon: '💧',
    items: [
      S('shared-sayyid-istighfar', id: 'sayyid-istighfar'),
      S('shared-astaghfirullah', id: 'astaghfirullah'),
      const AdhkarItem(
        id: 'istighfar-short',
        contentId: 'istighfar-short',
        arabicText: 'أَسْتَغْفِرُ اللَّهَ',
        repetitions: 100,
        reference: 'صحيح البخاري',
        sourceBook: 'صحيح البخاري',
        authenticity: 'Sahih',
        translation: 'I ask Allah for forgiveness.',
      ),
    ],
  );

  static final repentance = AdhkarCategory(
    id: 'repentance',
    name: 'التوبة',
    nameEn: 'Repentance',
    description: 'أدعية التوبة والرجوع إلى الله',
    descriptionEn: 'Supplications of repentance and returning to Allah',
    recommendedTime: 'عند التوبة',
    recommendedTimeEn: 'When repenting',
    icon: '🌿',
    items: [
      S('shared-prophetic-tawbah', id: 'repent-tawbah'),
      S('shared-quran-zalama', id: 'repent-zalama'),
      S('shared-sayyid-istighfar', id: 'repent-sayyid'),
      S('shared-yunus', id: 'repent-yunus'),
    ],
  );

  static final generalDhikr = AdhkarCategory(
    id: 'tasbeeh',
    name: 'الذكر العام',
    nameEn: 'General Dhikr',
    description: 'كلمات خفيفة على اللسان',
    descriptionEn: 'Short phrases of general remembrance',
    recommendedTime: 'في أي وقت',
    recommendedTimeEn: 'Any time',
    icon: '🟢',
    items: [
      S('shared-subhan-bihamdihi', id: 'subhan-bihamdihi'),
      S('shared-subhan-azeem', id: 'subhan-azeem'),
      S('shared-tahlil', id: 'tahlil-hundred'),
      S('shared-four', id: 'general-four'),
      S('shared-hawqalah', id: 'general-hawqalah'),
      S('shared-alhamdulillah', id: 'general-hamd'),
      const AdhkarItem(
        id: 'general-takbir',
        contentId: 'general-takbir',
        arabicText: 'اللَّهُ أَكْبَرُ',
        repetitions: 33,
        reference: 'صحيح مسلم',
        sourceBook: 'صحيح مسلم',
        authenticity: 'Sahih',
        translation: 'Allah is the Greatest.',
      ),
    ],
  );

  static final quranicDuas = AdhkarCategory(
    id: 'quranic_duas',
    name: 'أدعية قرآنية',
    nameEn: 'Quranic Supplications',
    description: 'أدعية ثابتة بألفاظ القرآن',
    descriptionEn: 'Supplications in the words of the Quran',
    recommendedTime: 'في الدعاء',
    recommendedTimeEn: 'In supplication',
    icon: '📖',
    items: [
      S('shared-rabbana-atina', id: 'quran-rabbana-atina'),
      S('shared-rabbi-zidni', id: 'quran-rabbi-zidni'),
      S('shared-quran-hearts', id: 'quran-hearts'),
      S('shared-quran-chest', id: 'quran-chest'),
      S('shared-quran-zalama', id: 'quran-zalama'),
      S('shared-quran-ibrahim', id: 'quran-ibrahim'),
      S('shared-yunus', id: 'quran-yunus'),
      S('shared-hasbunallah', id: 'quran-hasbunallah'),
      S('shared-quran-shukr', id: 'quran-shukr'),
      S('shared-quran-parents', id: 'quran-parents'),
    ],
  );

  static final prophetic = AdhkarCategory(
    id: 'prophetic',
    name: 'أدعية نبوية',
    nameEn: 'Prophetic Supplications',
    description: 'من الأدعية الثابتة عن النبي ﷺ',
    descriptionEn: 'Supplications reported from the Prophet ﷺ',
    recommendedTime: 'في الصلاة وبعدها',
    recommendedTimeEn: 'In and after prayer',
    icon: '☾',
    items: [
      S('shared-salawat', id: 'salawat'),
      S('shared-prophetic-huda', id: 'prophetic-huda'),
      S('shared-prophetic-tawbah', id: 'prophetic-tawbah'),
      S('shared-anxiety-hamm', id: 'prophetic-hamm'),
      S('shared-sayyid-istighfar', id: 'prophetic-sayyid'),
      S('shared-afiyah', id: 'prophetic-afiyah'),
      S('shared-hasbunallah', id: 'hasbunallah'),
    ],
  );

  static final friday = AdhkarCategory(
    id: 'friday',
    name: 'أذكار الجمعة',
    nameEn: 'Friday',
    description: 'ما يُستحب يوم الجمعة',
    descriptionEn: 'Recommended acts on Friday',
    recommendedTime: 'يوم الجمعة',
    recommendedTimeEn: 'On Friday',
    icon: '📿',
    items: [
      S('shared-salawat', id: 'friday-salawat').copyWith(
        repetitions: 10,
        explanation:
            'ورد الإكثار من الصلاة على النبي ﷺ يوم الجمعة في سنن أبي داود. والعشر هنا عدّاد للتذكير.',
      ),
      const AdhkarItem(
        id: 'friday-kahf',
        contentId: 'friday-kahf',
        arabicText: 'قراءة سورة الكهف',
        repetitions: 1,
        reference: 'رواه الحاكم والبيهقي، ويُراجع تخريجه في كتب السنن',
        translation: 'Recite Surat al-Kahf.',
        explanation:
            'ورد فضل قراءة سورة الكهف يوم الجمعة عند الحاكم والبيهقي. اقرأ السورة من المصحف؛ هذا العنصر تذكير وليس نص السورة.',
      ),
      S('shared-astaghfirullah', id: 'friday-istighfar'),
    ],
  );

  static final protection = AdhkarCategory(
    id: 'protection',
    name: 'الحماية والتحصين',
    nameEn: 'Protection',
    description: 'أذكار التحصين والاستعاذة',
    descriptionEn: 'Remembrances of protection and seeking refuge',
    recommendedTime: 'صباحاً ومساءً وعند الحاجة',
    recommendedTimeEn: 'Morning, evening, and when needed',
    icon: '🛡',
    items: [
      S('shared-ayat-kursi', id: 'protect-kursi'),
      S('shared-ikhlas', id: 'protect-ikhlas'),
      S('shared-falaq', id: 'protect-falaq'),
      S('shared-nas', id: 'protect-nas'),
      S('shared-kalimat', id: 'protect-kalimat'),
      S('shared-bismillah-protect', id: 'protect-bismillah'),
      S('shared-hasbiyallah', id: 'protect-hasbiyallah'),
      S('shared-afiyah', id: 'protect-afiyah'),
    ],
  );

  static final anxiety = AdhkarCategory(
    id: 'anxiety',
    name: 'الهم والكرب',
    nameEn: 'Anxiety / Difficult Times',
    description: 'أدعية الهم والحزن',
    descriptionEn: 'Supplications for worry and grief',
    recommendedTime: 'عند الكرب',
    recommendedTimeEn: 'In distress',
    icon: '🤍',
    items: [
      S('shared-anxiety-hamm', id: 'anxiety-hamm'),
      S('shared-yunus', id: 'anxiety-yunus'),
      S('shared-hasbunallah', id: 'anxiety-hasbunallah'),
      S('shared-hawqalah', id: 'anxiety-hawqalah'),
      S('shared-quran-hearts', id: 'anxiety-hearts'),
    ],
  );

  static final gratitude = AdhkarCategory(
    id: 'gratitude',
    name: 'الشكر',
    nameEn: 'Gratitude',
    description: 'حمد الله والاعتراف بنعمه',
    descriptionEn: 'Praising Allah and acknowledging His favors',
    recommendedTime: 'عند النعمة وبعد الطعام',
    recommendedTimeEn: 'When blessed and after food',
    icon: '💛',
    items: [
      S('shared-alhamdulillah', id: 'gratitude-hamd'),
      S('shared-quran-shukr', id: 'gratitude-shukr'),
      S('shared-ate-hamd', id: 'gratitude-ate'),
      S('shared-subhan-bihamdihi', id: 'gratitude-subhan'),
      S('shared-four', id: 'gratitude-four'),
    ],
  );

  static final dailyDuas = AdhkarCategory(
    id: 'daily_duas',
    name: 'أدعية يومية',
    nameEn: 'Daily Duas',
    description: 'أدعية جامعة تُقال في اليوم',
    descriptionEn: 'Short authentic daily supplications',
    recommendedTime: 'خلال اليوم',
    recommendedTimeEn: 'Through the day',
    icon: '✨',
    items: [
      S('shared-rabbana-atina', id: 'rabbana-atina'),
      S('shared-rabbi-zidni', id: 'rabbi-zidni'),
      S('shared-kalimat', id: 'daily-kalimat'),
      S('shared-hawqalah', id: 'daily-hawqalah'),
      S('shared-quran-parents', id: 'daily-parents'),
    ],
  );
}
