import '../models/islamic_quiz.dart';

/// Topic metadata for home cards (names/descriptions via localization keys).
class QuizTopicInfo {
  final QuizTopic topic;
  final String nameKey;
  final String descriptionKey;
  final int accent;

  const QuizTopicInfo({
    required this.topic,
    required this.nameKey,
    required this.descriptionKey,
    required this.accent,
  });
}

/// Verified educational quiz bank.
///
/// Sources are limited to widely taught, documentable facts from:
/// - The Quran (Uthmani mushaf structure and clear verses)
/// - Sahih al-Bukhari / Sahih Muslim (and well-known collection authorship)
/// - Established Seerah events taught across mainstream Sirah works
///   (e.g. Ibn Hisham / Ibn Ishaq tradition) that are not contested as events
///
/// Disputed scholarly opinions are not used as the graded answer. Where a
/// nuance exists, [QuizQuestion.cautionEn] notes it without changing scoring.
class IslamicQuizCatalog {
  IslamicQuizCatalog._();

  static const attributionEn =
      'Educational quiz bank: Quran structure and clear verses; '
      'Sahih al-Bukhari and Sahih Muslim for creed/worship basics; '
      'widely established Seerah and early history events. '
      'Not a fatwa source. Disputed matters are not graded as universal fact.';

  static const attributionAr =
      'بنك أسئلة تعليمي: بنية القرآن والآيات الواضحة؛ '
      'صحيح البخاري وصحيح مسلم لأساسيات العقيدة والعبادة؛ '
      'أحداث السيرة والتاريخ المبكر الثابتة على نطاق واسع. '
      'ليس مصدر فتوى. المسائل الخلافية لا تُحسب كحقائق مطلقة في التصحيح.';

  static const topics = <QuizTopicInfo>[
    QuizTopicInfo(
      topic: QuizTopic.quran,
      nameKey: 'quizTopicQuran',
      descriptionKey: 'quizTopicQuranDesc',
      accent: 0xFF0D7377,
    ),
    QuizTopicInfo(
      topic: QuizTopic.hadith,
      nameKey: 'quizTopicHadith',
      descriptionKey: 'quizTopicHadithDesc',
      accent: 0xFF8B6F47,
    ),
    QuizTopicInfo(
      topic: QuizTopic.seerah,
      nameKey: 'quizTopicSeerah',
      descriptionKey: 'quizTopicSeerahDesc',
      accent: 0xFF5B8C5A,
    ),
    QuizTopicInfo(
      topic: QuizTopic.prophets,
      nameKey: 'quizTopicProphets',
      descriptionKey: 'quizTopicProphetsDesc',
      accent: 0xFFC9A227,
    ),
    QuizTopicInfo(
      topic: QuizTopic.history,
      nameKey: 'quizTopicHistory',
      descriptionKey: 'quizTopicHistoryDesc',
      accent: 0xFF6B5B95,
    ),
    QuizTopicInfo(
      topic: QuizTopic.general,
      nameKey: 'quizTopicGeneral',
      descriptionKey: 'quizTopicGeneralDesc',
      accent: 0xFF3D7EA6,
    ),
  ];

  static final List<QuizQuestion> all = List.unmodifiable([
    ..._quran,
    ..._hadith,
    ..._seerah,
    ..._prophets,
    ..._history,
    ..._general,
  ]);

  static QuizQuestion? byId(String id) {
    for (final q in all) {
      if (q.id == id) return q;
    }
    return null;
  }

  static List<QuizQuestion> forTopic(
    QuizTopic topic, {
    QuizDifficulty? difficulty,
  }) {
    return all.where((q) {
      if (q.topic != topic) return false;
      if (difficulty != null && q.difficulty != difficulty) return false;
      return true;
    }).toList();
  }

  static List<QuizQuestion> byIds(Iterable<String> ids) {
    final map = {for (final q in all) q.id: q};
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  // --- Quran (Uthmani mushaf structure / clear Quranic facts) ---
  static const _quran = <QuizQuestion>[
    QuizQuestion(
      id: 'quran_surah_count',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'How many surahs (chapters) are in the Quran?',
      promptAr: 'كم عدد سور القرآن الكريم؟',
      optionsEn: ['99', '110', '114', '120'],
      optionsAr: ['٩٩', '١١٠', '١١٤', '١٢٠'],
      correctIndex: 2,
      explanationEn:
          'The standard Uthmani mushaf contains 114 surahs, from Al-Fatihah to An-Nas.',
      explanationAr:
          'المصحف العثماني المعتمد يحتوي على ١١٤ سورة، من الفاتحة إلى الناس.',
      sourceEn: 'Uthmani mushaf structure (universal Muslim practice)',
      sourceAr: 'بنية المصحف العثماني (ما عليه عمل المسلمين)',
    ),
    QuizQuestion(
      id: 'quran_juz_count',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Into how many ajzaʼ (juzʼ) is the Quran commonly divided?',
      promptAr: 'إلى كم جزءًا يُقسَّم القرآن عادة؟',
      optionsEn: ['7', '15', '30', '60'],
      optionsAr: ['٧', '١٥', '٣٠', '٦٠'],
      correctIndex: 2,
      explanationEn:
          'For ease of reading, the Quran is commonly divided into 30 juzʼ.',
      explanationAr:
          'للتيسير في القراءة، يُقسَّم القرآن عادة إلى ٣٠ جزءًا.',
      sourceEn: 'Standard Quranic division for recitation',
      sourceAr: 'التقسيم المصحفي الشائع للقراءة',
    ),
    QuizQuestion(
      id: 'quran_longest_surah',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Which is the longest surah in the Quran by ayah count?',
      promptAr: 'ما أطول سورة في القرآن بعدد الآيات؟',
      optionsEn: ['Al-Imran', 'An-Nisa', 'Al-Baqarah', 'Al-Maidah'],
      optionsAr: ['آل عمران', 'النساء', 'البقرة', 'المائدة'],
      correctIndex: 2,
      explanationEn:
          'Surah Al-Baqarah is the longest surah in the Quran (286 ayahs in the Uthmani mushaf).',
      explanationAr:
          'سورة البقرة أطول سور القرآن (٢٨٦ آية في المصحف العثماني).',
      sourceEn: 'Uthmani mushaf ayah counts',
      sourceAr: 'عدد آيات المصحف العثماني',
    ),
    QuizQuestion(
      id: 'quran_fatihah_opening',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'What is the opening surah of the Quran?',
      promptAr: 'ما السورة التي يُفتتح بها المصحف؟',
      optionsEn: ['Al-Baqarah', 'Al-Fatihah', 'Al-Ikhlas', 'An-Nas'],
      optionsAr: ['البقرة', 'الفاتحة', 'الإخلاص', 'الناس'],
      correctIndex: 1,
      explanationEn:
          'Al-Fatihah is the first surah in the mushaf and is recited in every unit of prayer.',
      explanationAr:
          'الفاتحة أول سورة في المصحف، وتُقرأ في كل ركعة من الصلاة.',
      sourceEn: 'Quran arrangement; prayer practice from the Sunnah',
      sourceAr: 'ترتيب المصحف؛ وسنة قراءة الفاتحة في الصلاة',
    ),
    QuizQuestion(
      id: 'quran_kawthar_shortest',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Which is the shortest surah in the Quran by ayah count?',
      promptAr: 'ما أقصر سورة في القرآن بعدد الآيات؟',
      optionsEn: ['Al-Asr', 'Al-Kawthar', 'Al-Ikhlas', 'Al-Fil'],
      optionsAr: ['العصر', 'الكوثر', 'الإخلاص', 'الفيل'],
      correctIndex: 1,
      explanationEn:
          'Surah Al-Kawthar has three ayahs and is the shortest surah by ayah count.',
      explanationAr:
          'سورة الكوثر ثلاث آيات، وهي أقصر سورة بعدد الآيات.',
      sourceEn: 'Uthmani mushaf ayah counts',
      sourceAr: 'عدد آيات المصحف العثماني',
    ),
    QuizQuestion(
      id: 'quran_last_prophet_verse',
      topic: QuizTopic.quran,
      difficulty: QuizDifficulty.advanced,
      promptEn:
          'Which verse states that Muhammad ﷺ is the Seal of the Prophets?',
      promptAr: 'أي آية تبيّن أن محمدًا ﷺ خاتم النبيين؟',
      optionsEn: [
        'Al-Baqarah 2:255',
        'Al-Ahzab 33:40',
        'Al-Ikhlas 112:1',
        'An-Nisa 4:1',
      ],
      optionsAr: [
        'البقرة ٢:٢٥٥',
        'الأحزاب ٣٣:٤٠',
        'الإخلاص ١١٢:١',
        'النساء ٤:١',
      ],
      correctIndex: 1,
      explanationEn:
          'Allah says in Al-Ahzab 33:40 that Muhammad ﷺ is the Messenger of Allah and the Seal of the Prophets.',
      explanationAr:
          'قال الله تعالى في الأحزاب ٣٣:٤٠ إن محمدًا ﷺ رسول الله وخاتم النبيين.',
      sourceEn: 'Quran 33:40',
      sourceAr: 'القرآن الكريم، الأحزاب: ٤٠',
    ),
  ];

  // --- Hadith (Bukhari / Muslim / collection authorship) ---
  static const _hadith = <QuizQuestion>[
    QuizQuestion(
      id: 'hadith_intentions',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.beginner,
      promptEn:
          'According to a famous hadith in Sahih al-Bukhari, actions are judged by what?',
      promptAr:
          'بحسب حديث مشهور في صحيح البخاري، إنما الأعمال بماذا؟',
      optionsEn: ['Speech', 'Intentions', 'Wealth', 'Lineage'],
      optionsAr: ['الكلام', 'النيات', 'المال', 'النسب'],
      correctIndex: 1,
      explanationEn:
          'The Prophet ﷺ said: “Actions are but by intention…” This opens Sahih al-Bukhari.',
      explanationAr:
          'قال النبي ﷺ: «إنما الأعمال بالنيات…» وهو مما افتُتح به صحيح البخاري.',
      sourceEn: 'Sahih al-Bukhari, Book of Revelation, Hadith 1',
      sourceAr: 'صحيح البخاري، كتاب بدء الوحي، الحديث ١',
    ),
    QuizQuestion(
      id: 'hadith_pillars_islam',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'How many pillars of Islam are listed in the famous hadith?',
      promptAr: 'كم ركنًا للإسلام ورد في الحديث المشهور؟',
      optionsEn: ['3', '4', '5', '6'],
      optionsAr: ['٣', '٤', '٥', '٦'],
      correctIndex: 2,
      explanationEn:
          'Islam is built on five: testimony, prayer, zakat, fasting Ramadan, and Hajj for those able.',
      explanationAr:
          'بُني الإسلام على خمس: الشهادتين، والصلاة، والزكاة، وصوم رمضان، والحج لمن استطاع.',
      sourceEn: 'Sahih al-Bukhari; Sahih Muslim (Hadith of Ibn Umar)',
      sourceAr: 'صحيح البخاري؛ صحيح مسلم (حديث ابن عمر)',
    ),
    QuizQuestion(
      id: 'hadith_iman_articles',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.intermediate,
      promptEn:
          'In the Hadith of Jibril, how many articles of faith (iman) are mentioned?',
      promptAr: 'في حديث جبريل، كم أصلًا للإيمان ذُكر؟',
      optionsEn: ['4', '5', '6', '7'],
      optionsAr: ['٤', '٥', '٦', '٧'],
      correctIndex: 2,
      explanationEn:
          'Iman is belief in Allah, His angels, His books, His messengers, the Last Day, and divine decree.',
      explanationAr:
          'الإيمان أن تؤمن بالله وملائكته وكتبه ورسله واليوم الآخر والقدر خيره وشره.',
      sourceEn: 'Sahih Muslim, Hadith of Jibril (also in Bukhari with wording variants)',
      sourceAr: 'صحيح مسلم، حديث جبريل (ورواه البخاري بألفاظ مقاربة)',
    ),
    QuizQuestion(
      id: 'hadith_bukhari_author',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Who compiled Sahih al-Bukhari?',
      promptAr: 'من ألّف صحيح البخاري؟',
      optionsEn: [
        'Imam Muslim',
        'Imam al-Bukhari',
        'Imam an-Nawawi',
        'Imam Malik',
      ],
      optionsAr: [
        'الإمام مسلم',
        'الإمام البخاري',
        'الإمام النووي',
        'الإمام مالك',
      ],
      correctIndex: 1,
      explanationEn:
          'Muhammad ibn Ismail al-Bukhari compiled Al-Jamiʿ al-Sahih, known as Sahih al-Bukhari.',
      explanationAr:
          'محمد بن إسماعيل البخاري ألّف الجامع الصحيح المعروف بصحيح البخاري.',
      sourceEn: 'Standard hadith literature / collection authorship',
      sourceAr: 'كتب الحديث المعتمدة / نسبة الجامع الصحيح',
    ),
    QuizQuestion(
      id: 'hadith_religion_sincerity',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.advanced,
      promptEn:
          'The Prophet ﷺ said “The religion is nasihah (sincere counsel).” Where is this preserved?',
      promptAr:
          'قال النبي ﷺ: «الدين النصيحة». أين يُحفظ هذا الحديث؟',
      optionsEn: [
        'Only in weak collections',
        'Sahih Muslim',
        'Only as a proverb',
        'Only in poetry',
      ],
      optionsAr: [
        'في روايات ضعيفة فقط',
        'صحيح مسلم',
        'كمثل شعبي فقط',
        'في الشعر فقط',
      ],
      correctIndex: 1,
      explanationEn:
          'Narrated from Tamim ad-Dari in Sahih Muslim: “The religion is nasihah…”',
      explanationAr:
          'رواه تميم الداري في صحيح مسلم: «الدين النصيحة…»',
      sourceEn: 'Sahih Muslim, Book of Faith',
      sourceAr: 'صحيح مسلم، كتاب الإيمان',
    ),
    QuizQuestion(
      id: 'hadith_nawawi_forty',
      topic: QuizTopic.hadith,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'An-Nawawi’s famous short collection contains about how many hadith?',
      promptAr: 'كم حديثًا تقريبًا في الأربعين النووية المشهورة؟',
      optionsEn: ['10', '40', '100', '500'],
      optionsAr: ['١٠', '٤٠', '١٠٠', '٥٠٠'],
      correctIndex: 1,
      explanationEn:
          'Imam an-Nawawi compiled about forty foundational hadith widely taught to students.',
      explanationAr:
          'جمع الإمام النووي نحو أربعين حديثًا جامعًا تُدرَّس للطلاب على نطاق واسع.',
      sourceEn: 'An-Nawawi, Al-Arbaʿin an-Nawawiyyah',
      sourceAr: 'النووي، الأربعون النووية',
    ),
  ];

  // --- Seerah (established events) ---
  static const _seerah = <QuizQuestion>[
    QuizQuestion(
      id: 'seerah_birthplace',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'In which city was the Prophet Muhammad ﷺ born?',
      promptAr: 'في أي مدينة وُلد النبي محمد ﷺ؟',
      optionsEn: ['Madinah', 'Taif', 'Makkah', 'Jerusalem'],
      optionsAr: ['المدينة', 'الطائف', 'مكة', 'القدس'],
      correctIndex: 2,
      explanationEn:
          'He ﷺ was born in Makkah. This is agreed across classical Sirah works.',
      explanationAr:
          'وُلد ﷺ في مكة، وهذا متفق عليه في كتب السيرة المعتمدة.',
      sourceEn: 'Classical Sirah (e.g. Ibn Hisham / Ibn Ishaq tradition)',
      sourceAr: 'السيرة النبوية الكلاسيكية (مثل ابن هشام / ابن إسحاق)',
    ),
    QuizQuestion(
      id: 'seerah_hijra_year',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'In which Gregorian year did the Hijra to Madinah occur?',
      promptAr: 'في أي سنة ميلادية كانت الهجرة إلى المدينة؟',
      optionsEn: ['570 CE', '610 CE', '622 CE', '632 CE'],
      optionsAr: ['٥٧٠ م', '٦١٠ م', '٦٢٢ م', '٦٣٢ م'],
      correctIndex: 2,
      explanationEn:
          'The Hijra in 622 CE marks year 1 AH in the Islamic calendar.',
      explanationAr:
          'كانت الهجرة سنة ٦٢٢ م، وهي بداية السنة الهجرية الأولى.',
      sourceEn: 'Islamic chronology / Sirah consensus on Hijra year',
      sourceAr: 'التأريخ الإسلامي / اتفاق السيرة على سنة الهجرة',
    ),
    QuizQuestion(
      id: 'seerah_first_wife',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Who was the first wife of the Prophet ﷺ?',
      promptAr: 'من أول زوجة للنبي ﷺ؟',
      optionsEn: ['Aishah', 'Hafsah', 'Khadijah', 'Sawdah'],
      optionsAr: ['عائشة', 'حفصة', 'خديجة', 'سودة'],
      correctIndex: 2,
      explanationEn:
          'Khadijah bint Khuwaylid (may Allah be pleased with her) was his first wife and a major early supporter of Islam.',
      explanationAr:
          'خديجة بنت خويلد رضي الله عنها أول زوجاته وأعظم نصيرات الإسلام في بدايته.',
      sourceEn: 'Classical Sirah and biographical literature',
      sourceAr: 'كتب السيرة والتراجم المعتمدة',
    ),
    QuizQuestion(
      id: 'seerah_first_revelation_place',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Where did the first revelation begin, according to the Sirah?',
      promptAr: 'أين بدأ نزول الوحي أول مرة بحسب السيرة؟',
      optionsEn: [
        'Cave of Hira',
        'Cave of Thawr',
        'Masjid an-Nabawi',
        'Mount Uhud',
      ],
      optionsAr: [
        'غار حراء',
        'غار ثور',
        'المسجد النبوي',
        'جبل أحد',
      ],
      correctIndex: 0,
      explanationEn:
          'The first revelation came while the Prophet ﷺ was in the Cave of Hira near Makkah.',
      explanationAr:
          'بدأ نزول الوحي والنبي ﷺ في غار حراء قرب مكة.',
      sourceEn: 'Sahih al-Bukhari (beginning of revelation); classical Sirah',
      sourceAr: 'صحيح البخاري (بدء الوحي)؛ السيرة النبوية',
    ),
    QuizQuestion(
      id: 'seerah_badr_year',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'In which Hijri year did the Battle of Badr take place?',
      promptAr: 'في أي سنة هجرية وقعت غزوة بدر؟',
      optionsEn: ['1 AH', '2 AH', '5 AH', '8 AH'],
      optionsAr: ['١ هـ', '٢ هـ', '٥ هـ', '٨ هـ'],
      correctIndex: 1,
      explanationEn:
          'The Battle of Badr occurred in Ramadan of 2 AH and is mentioned in the Quran.',
      explanationAr:
          'وقعت غزوة بدر في رمضان سنة ٢ هـ، وذُكرت في القرآن.',
      sourceEn: 'Quran (e.g. Al-Anfal context); classical Sirah chronology',
      sourceAr: 'القرآن (سياق الأنفال)؛ ترتيب السيرة',
    ),
    QuizQuestion(
      id: 'seerah_conquest_makkah',
      topic: QuizTopic.seerah,
      difficulty: QuizDifficulty.advanced,
      promptEn: 'In which Hijri year was the Conquest of Makkah?',
      promptAr: 'في أي سنة هجرية كان فتح مكة؟',
      optionsEn: ['2 AH', '5 AH', '8 AH', '10 AH'],
      optionsAr: ['٢ هـ', '٥ هـ', '٨ هـ', '١٠ هـ'],
      correctIndex: 2,
      explanationEn:
          'The Conquest of Makkah took place in 8 AH according to the established Sirah timeline.',
      explanationAr:
          'كان فتح مكة سنة ٨ هـ بحسب ترتيب السيرة المعتمد.',
      sourceEn: 'Classical Sirah chronology (Ibn Hisham et al.)',
      sourceAr: 'ترتيب السيرة عند ابن هشام وغيره',
    ),
  ];

  // --- Prophets (Quranic) ---
  static const _prophets = <QuizQuestion>[
    QuizQuestion(
      id: 'prophets_seal',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Who is the final prophet in Islam?',
      promptAr: 'من خاتم الأنبياء في الإسلام؟',
      optionsEn: ['Isa (Jesus)', 'Musa (Moses)', 'Muhammad ﷺ', 'Ibrahim'],
      optionsAr: ['عيسى', 'موسى', 'محمد ﷺ', 'إبراهيم'],
      correctIndex: 2,
      explanationEn:
          'Muhammad ﷺ is the Seal of the Prophets; no prophet comes after him.',
      explanationAr:
          'محمد ﷺ خاتم النبيين، لا نبي بعده.',
      sourceEn: 'Quran 33:40',
      sourceAr: 'القرآن الكريم، الأحزاب: ٤٠',
    ),
    QuizQuestion(
      id: 'prophets_first_human',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Who is the first human and prophet mentioned as the father of humankind?',
      promptAr: 'من أول البشر والنبي المذكور أبو البشرية؟',
      optionsEn: ['Nuh', 'Adam', 'Idris', 'Ibrahim'],
      optionsAr: ['نوح', 'آدم', 'إدريس', 'إبراهيم'],
      correctIndex: 1,
      explanationEn:
          'Adam (peace be upon him) is the first human created, as taught in the Quran.',
      explanationAr:
          'آدم عليه السلام أول البشر خلقًا كما جاء في القرآن.',
      sourceEn: 'Quran (e.g. Al-Baqarah 2:30–39 and related passages)',
      sourceAr: 'القرآن (مثل البقرة ٢:٣٠–٣٩ وما يتعلق بها)',
    ),
    QuizQuestion(
      id: 'prophets_ibrahim_title',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Which prophet is called Khalil Allah (Friend of Allah) in Islamic texts?',
      promptAr: 'أي نبي يُوصف بخليل الله في النصوص الإسلامية؟',
      optionsEn: ['Musa', 'Ibrahim', 'Yusuf', 'Yunus'],
      optionsAr: ['موسى', 'إبراهيم', 'يوسف', 'يونس'],
      correctIndex: 1,
      explanationEn:
          'Ibrahim (peace be upon him) is called Khalil Allah in the Quran and Sunnah.',
      explanationAr:
          'إبراهيم عليه السلام خليل الله كما في القرآن والسنة.',
      sourceEn: 'Quran 4:125; related authentic hadith',
      sourceAr: 'القرآن ٤:١٢٥؛ وأحاديث صحيحة ذات صلة',
    ),
    QuizQuestion(
      id: 'prophets_musa_book',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Which scripture was given to Musa (Moses), according to the Quran?',
      promptAr: 'أي كتاب أُنزل على موسى عليه السلام بحسب القرآن؟',
      optionsEn: ['Zabur', 'Injil', 'Tawrah', 'Suhuf only'],
      optionsAr: ['الزبور', 'الإنجيل', 'التوراة', 'صحف فقط'],
      correctIndex: 2,
      explanationEn:
          'The Quran states that Allah gave Musa the Tawrah (Torah).',
      explanationAr:
          'ذكر القرآن أن الله آتى موسى التوراة.',
      sourceEn: 'Quran (e.g. Al-Maidah 5:44; Al-Isra 17:2)',
      sourceAr: 'القرآن (مثل المائدة ٥:٤٤؛ الإسراء ١٧:٢)',
    ),
    QuizQuestion(
      id: 'prophets_isa_book',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'Which scripture was given to Isa (Jesus), according to the Quran?',
      promptAr: 'أي كتاب أُنزل على عيسى عليه السلام بحسب القرآن؟',
      optionsEn: ['Tawrah', 'Zabur', 'Injil', 'Quran'],
      optionsAr: ['التوراة', 'الزبور', 'الإنجيل', 'القرآن'],
      correctIndex: 2,
      explanationEn:
          'The Quran states that Allah gave Isa the Injil (Gospel).',
      explanationAr:
          'ذكر القرآن أن الله آتى عيسى الإنجيل.',
      sourceEn: 'Quran (e.g. Al-Maidah 5:46)',
      sourceAr: 'القرآن (مثل المائدة ٥:٤٦)',
    ),
    QuizQuestion(
      id: 'prophets_ulul_azm_count',
      topic: QuizTopic.prophets,
      difficulty: QuizDifficulty.advanced,
      promptEn:
          'How many “Ulul-Azm” (messengers of strong resolve) are commonly listed by scholars?',
      promptAr:
          'كم نبيًا من أولي العزم يذكرهم العلماء عادة؟',
      optionsEn: ['3', '5', '7', '10'],
      optionsAr: ['٣', '٥', '٧', '١٠'],
      correctIndex: 1,
      explanationEn:
          'Many scholars list five: Nuh, Ibrahim, Musa, Isa, and Muhammad ﷺ, based on Quranic pairing of strong resolve with these messengers.',
      explanationAr:
          'يذكر كثير من العلماء خمسة: نوح وإبراهيم وموسى وعيسى ومحمد ﷺ، استنادًا إلى ما ورد في القرآن عن أولي العزم.',
      sourceEn:
          'Quran 46:35; 42:13; classical tafsir listing of five Ulul-Azm',
      sourceAr:
          'القرآن ٤٦:٣٥؛ ٤٢:١٣؛ وتفسير العلماء لخمسة من أولي العزم',
      cautionEn:
          'Exact naming of the five is a scholarly listing drawn from Quranic themes, not a single numbered verse.',
      cautionAr:
          'تسمية الخمسة قائمة علمية مستنبطة من القرآن، وليست من آية واحدة تعددهم بأرقام.',
    ),
  ];

  // --- Islamic history (widely taught early chronology; avoid sectarian rulings) ---
  static const _history = <QuizQuestion>[
    QuizQuestion(
      id: 'history_hijri_start',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'What event marks the start of the Islamic (Hijri) calendar?',
      promptAr: 'ما الحدث الذي يبدأ منه التقويم الهجري؟',
      optionsEn: [
        'Birth of the Prophet ﷺ',
        'First revelation',
        'Hijra to Madinah',
        'Conquest of Makkah',
      ],
      optionsAr: [
        'مولد النبي ﷺ',
        'بدء الوحي',
        'الهجرة إلى المدينة',
        'فتح مكة',
      ],
      correctIndex: 2,
      explanationEn:
          'The Hijri calendar begins from the Hijra of the Prophet ﷺ to Madinah.',
      explanationAr:
          'يبدأ التقويم الهجري من هجرة النبي ﷺ إلى المدينة.',
      sourceEn: 'Islamic chronological convention established under Umar',
      sourceAr: 'اصطلاح التأريخ الهجري المتقرر في عهد عمر',
    ),
    QuizQuestion(
      id: 'history_rashidun_count',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.beginner,
      promptEn:
          'In Sunni historical teaching, how many Rightly Guided Caliphs (Khulafa ar-Rashidun) are commonly counted?',
      promptAr:
          'في التدريس التاريخي السني، كم عدد الخلفاء الراشدين الذين يُذكرون عادة؟',
      optionsEn: ['2', '3', '4', '12'],
      optionsAr: ['٢', '٣', '٤', '١٢'],
      correctIndex: 2,
      explanationEn:
          'Sunni historical curricula commonly list four: Abu Bakr, Umar, Uthman, and Ali (may Allah be pleased with them).',
      explanationAr:
          'تُذكر عادة أربعة في المناهج التاريخية السنية: أبو بكر وعمر وعثمان وعلي رضي الله عنهم.',
      sourceEn: 'Sunni historical tradition of the Rashidun period',
      sourceAr: 'التقليد التاريخي السني لعهد الخلفاء الراشدين',
      cautionEn:
          'Political succession after the Prophet ﷺ is discussed differently across Muslim traditions; this item reflects the common Sunni historical listing, not a sectarian polemic.',
      cautionAr:
          'يختلف المسلمون في مسائل الخلافة؛ هذا السؤال يعكس التعداد التاريخي السني الشائع لا جدلًا مذهبيًا.',
    ),
    QuizQuestion(
      id: 'history_first_caliph_sunni',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.intermediate,
      promptEn:
          'In the Sunni historical narrative, who was the first caliph after the Prophet ﷺ?',
      promptAr:
          'بحسب الرواية التاريخية السنية، من أول خليفة بعد النبي ﷺ؟',
      optionsEn: ['Umar', 'Uthman', 'Abu Bakr', 'Ali'],
      optionsAr: ['عمر', 'عثمان', 'أبو بكر', 'علي'],
      correctIndex: 2,
      explanationEn:
          'Abu Bakr as-Siddiq (may Allah be pleased with him) became the first caliph in the Sunni historical account.',
      explanationAr:
          'أبو بكر الصديق رضي الله عنه أول الخلفاء في الرواية التاريخية السنية.',
      sourceEn: 'Early Islamic historical sources (Sunni chronology)',
      sourceAr: 'مصادر التاريخ الإسلامي المبكر (التسلسل السني)',
      cautionEn:
          'Presented as Sunni historical narrative, not as a universal creed question.',
      cautionAr:
          'يُعرض كرواية تاريخية سنية، لا كمسألة اعتقاد مطلقة لكل المسلمين.',
    ),
    QuizQuestion(
      id: 'history_uthman_mushaf',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.intermediate,
      promptEn:
          'Under which caliph was the Quranic mushaf standardized and copies sent to the regions?',
      promptAr:
          'في عهد أي خليفة وُحِّد رسم المصحف وأُرسلت نسخ إلى الأمصار؟',
      optionsEn: ['Abu Bakr', 'Umar', 'Uthman', 'Ali'],
      optionsAr: ['أبو بكر', 'عمر', 'عثمان', 'علي'],
      correctIndex: 2,
      explanationEn:
          'During the caliphate of Uthman ibn Affan, an official mushaf was standardized and distributed.',
      explanationAr:
          'في خلافة عثمان بن عفان وُحِّد المصحف وأُرسلت نسخه إلى الأمصار.',
      sourceEn: 'Hadith/history reports on the Uthmanic mushaf (e.g. Bukhari)',
      sourceAr: 'روايات جمع المصحف العثماني (مثل البخاري)',
    ),
    QuizQuestion(
      id: 'history_uhud_year',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.advanced,
      promptEn: 'In which Hijri year did the Battle of Uhud occur?',
      promptAr: 'في أي سنة هجرية وقعت غزوة أحد؟',
      optionsEn: ['2 AH', '3 AH', '5 AH', '8 AH'],
      optionsAr: ['٢ هـ', '٣ هـ', '٥ هـ', '٨ هـ'],
      correctIndex: 1,
      explanationEn:
          'Uhud took place in Shawwal of 3 AH according to the established Sirah timeline.',
      explanationAr:
          'وقعت أحد في شوال سنة ٣ هـ بحسب ترتيب السيرة.',
      sourceEn: 'Classical Sirah chronology',
      sourceAr: 'ترتيب السيرة النبوية',
    ),
    QuizQuestion(
      id: 'history_khandaq_year',
      topic: QuizTopic.history,
      difficulty: QuizDifficulty.advanced,
      promptEn: 'In which Hijri year did the Battle of the Trench (Al-Khandaq) occur?',
      promptAr: 'في أي سنة هجرية وقعت غزوة الخندق؟',
      optionsEn: ['2 AH', '3 AH', '5 AH', '9 AH'],
      optionsAr: ['٢ هـ', '٣ هـ', '٥ هـ', '٩ هـ'],
      correctIndex: 2,
      explanationEn:
          'The Battle of the Trench (Ahzab) is dated to 5 AH in classical Sirah works.',
      explanationAr:
          'تُؤرَّخ غزوة الخندق (الأحزاب) بسنة ٥ هـ في كتب السيرة.',
      sourceEn: 'Classical Sirah chronology; Quran Surah Al-Ahzab context',
      sourceAr: 'ترتيب السيرة؛ سياق سورة الأحزاب',
    ),
  ];

  // --- General Islamic knowledge ---
  static const _general = <QuizQuestion>[
    QuizQuestion(
      id: 'general_qibla',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'Toward which structure do Muslims face in prayer (qibla)?',
      promptAr: 'إلى أي شيء يتجه المسلمون في الصلاة (القبلة)؟',
      optionsEn: [
        'The Prophet’s grave',
        'The Kaaba in Makkah',
        'Jerusalem only',
        'Any mosque mihrab without reference',
      ],
      optionsAr: [
        'قبر النبي ﷺ',
        'الكعبة في مكة',
        'القدس فقط',
        'أي محراب بلا مرجع',
      ],
      correctIndex: 1,
      explanationEn:
          'The qibla is the Kaaba in Makkah. Facing it is required in prayer when able.',
      explanationAr:
          'القبلة هي الكعبة في مكة، واستقبالها واجب في الصلاة مع القدرة.',
      sourceEn: 'Quran 2:144; prayer rulings in fiqh based on Quran and Sunnah',
      sourceAr: 'القرآن ٢:١٤٤؛ أحكام الصلاة المبنية على الكتاب والسنة',
    ),
    QuizQuestion(
      id: 'general_ramadan',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'In which month is fasting obligatory for capable adult Muslims?',
      promptAr: 'في أي شهر يجب الصيام على المسلم البالغ القادر؟',
      optionsEn: ['Muharram', 'Rajab', 'Ramadan', 'Dhul-Hijjah'],
      optionsAr: ['محرم', 'رجب', 'رمضان', 'ذو الحجة'],
      correctIndex: 2,
      explanationEn:
          'Fasting the month of Ramadan is one of the five pillars of Islam.',
      explanationAr:
          'صيام شهر رمضان ركن من أركان الإسلام الخمسة.',
      sourceEn: 'Quran 2:183–185; Hadith of the five pillars',
      sourceAr: 'القرآن ٢:١٨٣–١٨٥؛ حديث أركان الإسلام',
    ),
    QuizQuestion(
      id: 'general_zakat',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.beginner,
      promptEn: 'What is zakat in the five pillars?',
      promptAr: 'ما الزكاة ضمن أركان الإسلام؟',
      optionsEn: [
        'Optional charity only',
        'Obligatory alms on qualifying wealth',
        'A type of prayer',
        'A pilgrimage rite only',
      ],
      optionsAr: [
        'صدقة نافلة فقط',
        'زكاة واجبة في المال بشروطه',
        'نوع من الصلاة',
        'منسك حج فقط',
      ],
      correctIndex: 1,
      explanationEn:
          'Zakat is the obligatory alms due on qualifying wealth and is a pillar of Islam.',
      explanationAr:
          'الزكاة فريضة في المال بشروطه، وهي ركن من أركان الإسلام.',
      sourceEn: 'Quran (e.g. 9:60; 2:43); Hadith of the five pillars',
      sourceAr: 'القرآن (مثل ٩:٦٠؛ ٢:٤٣)؛ حديث أركان الإسلام',
    ),
    QuizQuestion(
      id: 'general_hajj_once',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'How often is Hajj obligatory in a lifetime for those who are able?',
      promptAr: 'كم مرة يجب الحج في العمر على المستطيع؟',
      optionsEn: [
        'Every year',
        'Once in a lifetime',
        'Twice',
        'Only if living in Makkah',
      ],
      optionsAr: [
        'كل سنة',
        'مرة واحدة في العمر',
        'مرتين',
        'فقط لمن يسكن مكة',
      ],
      correctIndex: 1,
      explanationEn:
          'Hajj is obligatory once in a lifetime for those who have the means and ability.',
      explanationAr:
          'الحج واجب مرة واحدة في العمر على من استطاع إليه سبيلًا.',
      sourceEn: 'Quran 3:97; Hadith literature on Hajj obligation',
      sourceAr: 'القرآن ٣:٩٧؛ أحاديث وجوب الحج مرة',
    ),
    QuizQuestion(
      id: 'general_wudu_prayer',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.intermediate,
      promptEn: 'What purification is generally required before prayer when one is in a state of minor impurity?',
      promptAr: 'ما الطهارة المطلوبة عمومًا قبل الصلاة عند الحدث الأصغر؟',
      optionsEn: ['Only tayammum always', 'Wudu (ablution)', 'Ghusl always', 'No purification'],
      optionsAr: ['التيمم دائمًا فقط', 'الوضوء', 'الغسل دائمًا', 'لا طهارة'],
      correctIndex: 1,
      explanationEn:
          'Wudu is required for prayer when in a state of minor impurity, as taught in Quran and Sunnah.',
      explanationAr:
          'الوضوء مطلوب للصلاة عند الحدث الأصغر كما في الكتاب والسنة.',
      sourceEn: 'Quran 5:6; prophetic practice of wudu before prayer',
      sourceAr: 'القرآن ٥:٦؛ سنة الوضوء قبل الصلاة',
    ),
    QuizQuestion(
      id: 'general_friday_prayer',
      topic: QuizTopic.general,
      difficulty: QuizDifficulty.advanced,
      promptEn:
          'Which weekly congregational prayer is specifically commanded in Surah Al-Jumuʿah?',
      promptAr: 'أي صلاة أسبوعية جماعية أُمر بها خصوصًا في سورة الجمعة؟',
      optionsEn: [
        'Eid prayer',
        'Jumuʿah (Friday) prayer',
        'Tarawih',
        'Duha only',
      ],
      optionsAr: [
        'صلاة العيد',
        'صلاة الجمعة',
        'التراويح',
        'الضحى فقط',
      ],
      correctIndex: 1,
      explanationEn:
          'Surah Al-Jumuʿah calls believers to leave trade and hasten to the remembrance of Allah when the Friday call is made.',
      explanationAr:
          'سورة الجمعة تأمر المؤمنين بترك البيع والسعي إلى ذكر الله عند النداء يوم الجمعة.',
      sourceEn: 'Quran 62:9',
      sourceAr: 'القرآن الكريم، الجمعة: ٩',
    ),
  ];
}
