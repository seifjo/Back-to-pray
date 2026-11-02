import '../models/adhkar.dart';

/// Canonical Adhkar / dua entries shared across categories.
///
/// Rules:
/// - Quranic Arabic is quoted with surah:ayah.
/// - Prophetic wordings cite Bukhari, Muslim, or the Sunan named in [reference].
/// - [authenticity] is set only when the report is in Sahih al-Bukhari or
///   Sahih Muslim (marked Sahih), or left null when grading is not asserted here.
/// - Never invent reference numbers; leave [referenceNumber] null when unsure.
class AdhkarSharedCatalog {
  AdhkarSharedCatalog._();

  static final Map<String, AdhkarItem> _byId = {
    for (final item in all) item.contentId: item,
  };

  static AdhkarItem? byContentId(String contentId) => _byId[contentId];

  /// Place a shared entry into a category with a local progress id.
  static AdhkarItem place(String contentId, {required String id}) {
    final base = _byId[contentId];
    if (base == null) {
      throw ArgumentError.value(contentId, 'contentId', 'Unknown shared entry');
    }
    return base.copyWith(id: id);
  }

  static List<AdhkarItem> placeAll(
    List<(String contentId, String id)> entries,
  ) {
    return [
      for (final entry in entries) place(entry.$1, id: entry.$2),
    ];
  }

  static const List<AdhkarItem> all = [
    // —— Quran ——
    AdhkarItem(
      id: 'shared-ayat-kursi',
      contentId: 'shared-ayat-kursi',
      arabicText:
          'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      repetitions: 1,
      reference: 'البقرة: 255',
      sourceBook: 'القرآن الكريم',
      translation: 'Ayat al-Kursi (Al-Baqarah 2:255).',
      authenticity: null,
    ),
    AdhkarItem(
      id: 'shared-ikhlas',
      contentId: 'shared-ikhlas',
      arabicText:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾ اللَّهُ الصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ ﴿٤﴾',
      repetitions: 3,
      reference: 'سورة الإخلاص',
      sourceBook: 'القرآن الكريم',
      translation: 'Surah Al-Ikhlas (complete).',
    ),
    AdhkarItem(
      id: 'shared-falaq',
      contentId: 'shared-falaq',
      arabicText:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿٤﴾ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
      repetitions: 3,
      reference: 'سورة الفلق',
      sourceBook: 'القرآن الكريم',
      translation: 'Surah Al-Falaq (complete).',
    ),
    AdhkarItem(
      id: 'shared-nas',
      contentId: 'shared-nas',
      arabicText:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ﴿١﴾ مَلِكِ النَّاسِ ﴿٢﴾ إِلَٰهِ النَّاسِ ﴿٣﴾ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿٤﴾ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿٥﴾ مِنَ الْجِنَّةِ وَالنَّاسِ ﴿٦﴾',
      repetitions: 3,
      reference: 'سورة الناس',
      sourceBook: 'القرآن الكريم',
      translation: 'Surah An-Nas (complete).',
    ),
    AdhkarItem(
      id: 'shared-baqarah-end',
      contentId: 'shared-baqarah-end',
      arabicText:
          'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      repetitions: 1,
      reference: 'البقرة: 285-286',
      sourceBook: 'القرآن الكريم',
      translation: 'The last two verses of Surat al-Baqarah (2:285–286).',
      explanation: 'ورد فضل قراءتهما في الليل في صحيح البخاري.',
    ),
    AdhkarItem(
      id: 'shared-rabbana-atina',
      contentId: 'shared-rabbana-atina',
      arabicText:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      repetitions: 1,
      reference: 'البقرة: 201',
      sourceBook: 'القرآن الكريم',
      translation:
          'Our Lord, give us in this world good and in the Hereafter good, and protect us from the punishment of the Fire.',
    ),
    AdhkarItem(
      id: 'shared-rabbi-zidni',
      contentId: 'shared-rabbi-zidni',
      arabicText: 'رَبِّ زِدْنِي عِلْمًا',
      repetitions: 1,
      reference: 'طه: 114',
      sourceBook: 'القرآن الكريم',
      translation: 'My Lord, increase me in knowledge.',
    ),
    AdhkarItem(
      id: 'shared-yunus',
      contentId: 'shared-yunus',
      arabicText:
          'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      repetitions: 1,
      reference: 'الأنبياء: 87',
      sourceBook: 'القرآن الكريم',
      translation:
          'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      explanation: 'دعاء يونس عليه السلام.',
    ),
    AdhkarItem(
      id: 'shared-hasbunallah',
      contentId: 'shared-hasbunallah',
      arabicText: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      repetitions: 1,
      reference: 'آل عمران: 173',
      sourceBook: 'القرآن الكريم',
      translation:
          'Sufficient for us is Allah, and He is the best disposer of affairs.',
      explanation: 'ورد ذكرها في صحيح البخاري عن الصحابة.',
    ),
    AdhkarItem(
      id: 'shared-quran-hearts',
      contentId: 'shared-quran-hearts',
      arabicText:
          'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      repetitions: 1,
      reference: 'آل عمران: 8',
      sourceBook: 'القرآن الكريم',
      translation:
          'Our Lord, let not our hearts deviate after You have guided us, and grant us from Yourself mercy. Indeed, You are the Bestower.',
    ),
    AdhkarItem(
      id: 'shared-quran-chest',
      contentId: 'shared-quran-chest',
      arabicText:
          'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
      repetitions: 1,
      reference: 'طه: 25-28',
      sourceBook: 'القرآن الكريم',
      translation:
          'My Lord, expand for me my breast, ease for me my task, and untie the knot from my tongue that they may understand my speech.',
    ),
    AdhkarItem(
      id: 'shared-quran-zalama',
      contentId: 'shared-quran-zalama',
      arabicText:
          'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      repetitions: 1,
      reference: 'الأعراف: 23',
      sourceBook: 'القرآن الكريم',
      translation:
          'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
    ),
    AdhkarItem(
      id: 'shared-quran-ibrahim',
      contentId: 'shared-quran-ibrahim',
      arabicText:
          'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ. رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      repetitions: 1,
      reference: 'إبراهيم: 40-41',
      sourceBook: 'القرآن الكريم',
      translation:
          'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, and accept my supplication. Our Lord, forgive me and my parents and the believers the Day the account is established.',
    ),
    AdhkarItem(
      id: 'shared-quran-shukr',
      contentId: 'shared-quran-shukr',
      arabicText:
          'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَدْخِلْنِي بِرَحْمَتِكَ فِي عِبَادِكَ الصَّالِحِينَ',
      repetitions: 1,
      reference: 'النمل: 19',
      sourceBook: 'القرآن الكريم',
      translation:
          'My Lord, enable me to be grateful for Your favor which You have bestowed upon me and upon my parents, and to do righteousness of which You approve, and admit me by Your mercy into the ranks of Your righteous servants.',
    ),
    AdhkarItem(
      id: 'shared-quran-parents',
      contentId: 'shared-quran-parents',
      arabicText: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      repetitions: 1,
      reference: 'الإسراء: 24',
      sourceBook: 'القرآن الكريم',
      translation:
          'My Lord, have mercy upon them as they brought me up when I was small.',
    ),

    // —— Prophetic / Hisn-style ——
    AdhkarItem(
      id: 'shared-kalimat',
      contentId: 'shared-kalimat',
      arabicText: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      repetitions: 3,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation:
          'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    ),
    AdhkarItem(
      id: 'shared-sayyid-istighfar',
      contentId: 'shared-sayyid-istighfar',
      arabicText:
          'اللَّهُمَّ أَنتَ رَبِّي لَا إِلَهَ إِلَّا أَنتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنتَ',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      narrator: 'شداد بن أوس رضي الله عنه',
      translation: 'The master of seeking forgiveness (Sayyid al-Istighfar).',
    ),
    AdhkarItem(
      id: 'shared-astaghfirullah',
      contentId: 'shared-astaghfirullah',
      arabicText: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      repetitions: 100,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation: 'I seek Allah’s forgiveness and I repent to Him.',
      explanation:
          'في البخاري أن النبي ﷺ كان يستغفر الله ويتوب إليه في المجلس أكثر من سبعين مرة.',
    ),
    AdhkarItem(
      id: 'shared-subhan-bihamdihi',
      contentId: 'shared-subhan-bihamdihi',
      arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      repetitions: 100,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation: 'Glory is to Allah and praise is to Him.',
    ),
    AdhkarItem(
      id: 'shared-subhan-azeem',
      contentId: 'shared-subhan-azeem',
      arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation:
          'Glory is to Allah and praise is to Him. Glory is to Allah, the Magnificent.',
    ),
    AdhkarItem(
      id: 'shared-tahlil',
      contentId: 'shared-tahlil',
      arabicText:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      repetitions: 10,
      reference: 'صحيح البخاري ومسلم',
      sourceBook: 'صحيح البخاري ومسلم',
      authenticity: 'Sahih',
      translation:
          'None has the right to be worshipped except Allah, alone, without partner. To Him belongs dominion and praise, and He is over all things competent.',
    ),
    AdhkarItem(
      id: 'shared-hawqalah',
      contentId: 'shared-hawqalah',
      arabicText: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      repetitions: 1,
      reference: 'صحيح البخاري ومسلم',
      sourceBook: 'صحيح البخاري ومسلم',
      authenticity: 'Sahih',
      translation: 'There is no might nor power except with Allah.',
    ),
    AdhkarItem(
      id: 'shared-four',
      contentId: 'shared-four',
      arabicText:
          'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      repetitions: 1,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation:
          'Glory be to Allah, all praise is for Allah, there is no deity except Allah, and Allah is the Greatest.',
    ),
    AdhkarItem(
      id: 'shared-salawat',
      contentId: 'shared-salawat',
      arabicText:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation:
          'O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim. Indeed, You are Praiseworthy and Glorious. O Allah, bless Muhammad and the family of Muhammad, as You blessed Ibrahim and the family of Ibrahim. Indeed, You are Praiseworthy and Glorious.',
    ),
    AdhkarItem(
      id: 'shared-prophetic-huda',
      contentId: 'shared-prophetic-huda',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      repetitions: 1,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      narrator: 'عبد الله بن مسعود رضي الله عنه',
      translation:
          'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
    ),
    AdhkarItem(
      id: 'shared-prophetic-tawbah',
      contentId: 'shared-prophetic-tawbah',
      arabicText:
          'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
      repetitions: 1,
      reference: 'سنن أبي داود والترمذي',
      sourceBook: 'سنن أبي داود والترمذي',
      translation:
          'My Lord, forgive me and accept my repentance. Indeed, You are the Accepting of repentance, the Merciful.',
    ),
    AdhkarItem(
      id: 'shared-anxiety-hamm',
      contentId: 'shared-anxiety-hamm',
      arabicText:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرِّجَالِ',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation:
          'O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts, and being overpowered by men.',
    ),
    AdhkarItem(
      id: 'shared-bismillah-protect',
      contentId: 'shared-bismillah-protect',
      arabicText:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      repetitions: 3,
      reference: 'سنن أبي داود والترمذي',
      sourceBook: 'سنن أبي داود والترمذي',
      translation:
          'In the name of Allah, with whose name nothing on earth or in the heaven can cause harm, and He is the All-Hearing, the All-Knowing.',
    ),
    AdhkarItem(
      id: 'shared-raditu',
      contentId: 'shared-raditu',
      arabicText:
          'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
      repetitions: 3,
      reference: 'سنن أبي داود',
      sourceBook: 'سنن أبي داود',
      translation:
          'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as my Prophet.',
    ),
    AdhkarItem(
      id: 'shared-hasbiyallah',
      contentId: 'shared-hasbiyallah',
      arabicText:
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      repetitions: 7,
      reference: 'سنن أبي داود',
      sourceBook: 'سنن أبي داود',
      translation:
          'Allah is sufficient for me; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.',
    ),
    AdhkarItem(
      id: 'shared-afiyah',
      contentId: 'shared-afiyah',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِن بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَن يَمِينِي وَعَن شِمَالِي وَمِن فَوْقِي وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِن تَحْتِي',
      repetitions: 1,
      reference: 'سنن أبي داود وابن ماجه',
      sourceBook: 'سنن أبي داود وابن ماجه',
      translation:
          'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter. O Allah, I ask You for forgiveness and well-being in my religion, my worldly affairs, my family, and my wealth. O Allah, conceal my faults and calm my fears. O Allah, protect me from in front of me and behind me, from my right and my left, and from above me, and I seek refuge in Your greatness from being taken unaware from beneath me.',
    ),
    AdhkarItem(
      id: 'shared-asbahna',
      contentId: 'shared-asbahna',
      arabicText:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِن شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      repetitions: 1,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation:
          'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah alone, without partner. To Him belongs dominion and praise and He is over all things competent. My Lord, I ask You for the good of this day and the good of what follows it, and I seek refuge in You from the evil of this day and the evil of what follows it. My Lord, I seek refuge in You from laziness and senile old age. My Lord, I seek refuge in You from the punishment of Hellfire and the punishment of the grave.',
    ),
    AdhkarItem(
      id: 'shared-amsayna',
      contentId: 'shared-amsayna',
      arabicText:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِن شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      repetitions: 1,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation:
          'We have reached the evening and at this very time unto Allah belongs all sovereignty, and all praise is for Allah. None has the right to be worshipped except Allah alone, without partner. To Him belongs dominion and praise and He is over all things competent. My Lord, I ask You for the good of this night and the good of what follows it, and I seek refuge in You from the evil of this night and the evil of what follows it. My Lord, I seek refuge in You from laziness and senile old age. My Lord, I seek refuge in You from the punishment of Hellfire and the punishment of the grave.',
    ),
    AdhkarItem(
      id: 'shared-bika-asbahna',
      contentId: 'shared-bika-asbahna',
      arabicText:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
      repetitions: 1,
      reference: 'سنن الترمذي',
      sourceBook: 'سنن الترمذي',
      translation:
          'O Allah, by You we enter the morning, by You we enter the evening, by You we live, by You we die, and to You is the resurrection.',
    ),
    AdhkarItem(
      id: 'shared-bika-amsayna',
      contentId: 'shared-bika-amsayna',
      arabicText:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      repetitions: 1,
      reference: 'سنن الترمذي',
      sourceBook: 'سنن الترمذي',
      translation:
          'O Allah, by You we enter the evening, by You we enter the morning, by You we live, by You we die, and to You is the final return.',
    ),
    AdhkarItem(
      id: 'shared-sleep-bismika',
      contentId: 'shared-sleep-bismika',
      arabicText: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation: 'In Your name, O Allah, I die and I live.',
    ),
    AdhkarItem(
      id: 'shared-sleep-hands',
      contentId: 'shared-sleep-hands',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا مَنْجَا مِنكَ إِلَّا إِلَيْكَ، آمَنْتُ بِكِتَابِكَ الَّذِي أَنزَلْتَ، وَبِنَبِيِّكَ الَّذِي أَرْسَلْتَ',
      repetitions: 1,
      reference: 'صحيح البخاري ومسلم',
      sourceBook: 'صحيح البخاري ومسلم',
      authenticity: 'Sahih',
      translation:
          'O Allah, I submit myself to You, entrust my affairs to You, turn my face to You, and repose my back to You, hoping in You and fearing You. There is no refuge and no escape from You except to You. I believe in Your Book which You revealed and in Your Prophet whom You sent.',
    ),
    AdhkarItem(
      id: 'shared-waking-hamd',
      contentId: 'shared-waking-hamd',
      arabicText:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      repetitions: 1,
      reference: 'صحيح البخاري',
      sourceBook: 'صحيح البخاري',
      authenticity: 'Sahih',
      translation:
          'Praise is to Allah who gave us life after having taken it from us, and unto Him is the resurrection.',
    ),
    AdhkarItem(
      id: 'shared-waking-afiyah',
      contentId: 'shared-waking-afiyah',
      arabicText:
          'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ',
      repetitions: 1,
      reference: 'سنن الترمذي',
      sourceBook: 'سنن الترمذي',
      translation:
          'Praise is to Allah who granted me well-being in my body, returned my soul to me, and permitted me to remember Him.',
    ),
    AdhkarItem(
      id: 'shared-ate-hamd',
      contentId: 'shared-ate-hamd',
      arabicText:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      repetitions: 1,
      reference: 'سنن أبي داود والترمذي',
      sourceBook: 'سنن أبي داود والترمذي',
      translation:
          'Praise is to Allah who fed me this and provided it for me without any might or power from myself.',
    ),
    AdhkarItem(
      id: 'shared-alhamdulillah',
      contentId: 'shared-alhamdulillah',
      arabicText: 'الْحَمْدُ لِلَّهِ',
      repetitions: 33,
      reference: 'صحيح مسلم',
      sourceBook: 'صحيح مسلم',
      authenticity: 'Sahih',
      translation: 'All praise is for Allah.',
    ),
  ];
}
