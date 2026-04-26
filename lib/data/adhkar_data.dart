import '../models/adhkar.dart';

/// Adhkar Data
/// Complete authentic morning and evening adhkar in Arabic
class AdhkarData {
  static const AdhkarCategory morningAdhkar = AdhkarCategory(
    name: 'أذكار الصباح',
    description: 'الأذكار التي تُقال من بعد صلاة الفجر إلى طلوع الشمس',
    recommendedTime: 'من بعد صلاة الفجر حتى طلوع الشمس',
    items: [
       AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nاللّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
        repetitions: 1,
        reference: 'آية الكرسي - البقرة: 255',
        translation: 'Ayatul Kursi',
      ),
       AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ هُوَ ٱللَّهُ أَحَدٌ ﴿١﴾ ٱللَّهُ ٱلصَّمَدُ ﴿٢﴾ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ﴿٣﴾ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ ﴿٤﴾',
        repetitions: 3,
        reference: 'سورة الإخلاص',
        translation: 'Surah Al-Ikhlas (3 times)',
      ),
       AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلۡعُقَدِ ﴿٤﴾ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
        repetitions: 3,
        reference: 'سورة الفلق',
        translation: 'Surah Al-Falaq (3 times)',
      ),
       AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ﴿١﴾ مَلِكِ ٱلنَّاسِ ﴿٢﴾ إِلَٰهِ ٱلنَّاسِ ﴿٣﴾ مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ﴿٤﴾ ٱلَّذِى يُوَسۡوِسُ فِى صُدُورِ ٱلنَّاسِ ﴿٥﴾ مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ ﴿٦﴾',
        repetitions: 3,
        reference: 'سورة الناس',
        translation: 'Surah An-Nas (3 times)',
      ),
       AdhkarItem(
        arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
        repetitions: 1,
        reference: 'صحيح مسلم',
        translation: 'We have reached the morning and at this very time unto Allah belongs all sovereignty',
      ),
       AdhkarItem(
        arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ.',
        repetitions: 1,
        reference: 'سنن الترمذي',
        translation: 'O Allah, by You we enter the morning and by You we enter the evening',
      ),
       AdhkarItem(
        arabicText: 'رضيت بالله رباً وبالإسلام ديناً وبمحمد ﷺ نبياً',
        repetitions: 3,
        reference: 'سنن أبي داود',
        translation: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad as my Prophet',
      ),
       AdhkarItem(
        arabicText: 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم',
        repetitions: 7,
        reference: 'سنن أبي داود',
        translation: 'Allah is sufficient for me; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne',
      ),
       AdhkarItem(
        arabicText: 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة، اللهم إني أسألك العفو والعافية في ديني ودنياي وأهلي ومالي، اللهم استر عوراتي وآمن روعاتي، اللهم احفظني من بين يدي ومن خلفي وعن يميني وعن شمالي ومن فوقي وأعوذ بعظمتك أن أغتال من تحتي.',
        repetitions: 1,
        reference: 'سنن ابن ماجه',
        translation: 'O Allah, I ask You for forgiveness and well-being in this world and the Hereafter',
      ),
    ],
  );

  static const AdhkarCategory eveningAdhkar = AdhkarCategory(
    name: 'أذكار المساء',
    description: 'الأذكار التي تُقال من بعد صلاة العصر إلى غروب الشمس',
    recommendedTime: 'من بعد صلاة العصر حتى غروب الشمس',
    items: [
       AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nاللّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
        repetitions: 1,
        reference: 'آية الكرسي - البقرة: 255',
        translation: 'Ayatul Kursi',
      ),
      AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ هُوَ ٱللَّهُ أَحَدٌ ﴿١﴾ ٱللَّهُ ٱلصَّمَدُ ﴿٢﴾ لَمۡ يَلِدۡ وَلَمۡ يُولَدۡ ﴿٣﴾ وَلَمۡ يَكُن لَّهُۥ كُفُوًا أَحَدُۢ ﴿٤﴾',
        repetitions: 3,
        reference: 'سورة الإخلاص',
        translation: 'Surah Al-Ikhlas (3 times)',
      ),
      AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ ﴿١﴾ مِن شَرِّ مَا خَلَقَ ﴿٢﴾ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿٣﴾ وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلۡعُقَدِ ﴿٤﴾ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿٥﴾',
        repetitions: 3,
        reference: 'سورة الفلق',
        translation: 'Surah Al-Falaq (3 times)',
      ),
      AdhkarItem(
        arabicText: 'بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم\nقُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ ﴿١﴾ مَلِكِ ٱلنَّاسِ ﴿٢﴾ إِلَٰهِ ٱلنَّاسِ ﴿٣﴾ مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ ﴿٤﴾ ٱلَّذِى يُوَسۡوِسُ فِى صُدُورِ ٱلنَّاسِ ﴿٥﴾ مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ ﴿٦﴾',
        repetitions: 3,
        reference: 'سورة الناس',
        translation: 'Surah An-Nas (3 times)',
      ),
      AdhkarItem(
        arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
        repetitions: 1,
        reference: 'صحيح مسلم',
        translation: 'We have reached the evening and at this very time unto Allah belongs all sovereignty',
      ),
      AdhkarItem(
        arabicText: 'أعوذ بكلمات الله التامات من شر ما خلق',
        repetitions: 3,
        reference: 'صحيح مسلم',
        translation: 'I seek refuge in the Perfect Words of Allah from the evil of what He has created',
      ),
    ],
  );

  static List<AdhkarCategory> getAllAdhkar() {
    return [morningAdhkar, eveningAdhkar];
  }
}
