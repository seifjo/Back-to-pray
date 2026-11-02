import '../models/tasbeeh.dart';

/// Built-in dhikr with verified Arabic wording.
/// Traditional targets are labeled common practice, not invented hadith counts.
class TasbeehCatalog {
  static const builtIn = <TasbeehDhikr>[
    TasbeehDhikr(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      nameEn: 'Subhanallah',
      nameAr: 'سبحان الله',
      transliteration: 'Subhanallah',
      traditionalTarget: 33,
      traditionalNoteEn:
          'Commonly recited 33 times after the obligatory prayer, with al-hamdu lillah and Allahu akbar.',
      traditionalNoteAr:
          'يُذكر عادة ثلاثاً وثلاثين بعد الصلاة المفروضة مع الحمد لله والله أكبر.',
    ),
    TasbeehDhikr(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      nameEn: 'Alhamdulillah',
      nameAr: 'الحمد لله',
      transliteration: 'Alhamdulillah',
      traditionalTarget: 33,
      traditionalNoteEn:
          'Commonly recited 33 times after the obligatory prayer.',
      traditionalNoteAr: 'يُذكر عادة ثلاثاً وثلاثين بعد الصلاة المفروضة.',
    ),
    TasbeehDhikr(
      id: 'allahuakbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      nameEn: 'Allahu Akbar',
      nameAr: 'الله أكبر',
      transliteration: 'Allahu Akbar',
      traditionalTarget: 33,
      traditionalNoteEn:
          'Commonly recited 33 times after the obligatory prayer (some reports complete the hundred with a final takbir).',
      traditionalNoteAr:
          'يُذكر عادة ثلاثاً وثلاثين بعد الصلاة المفروضة، وفي بعض الروايات يُتمّ المائة بتكبيرة.',
    ),
    TasbeehDhikr(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      nameEn: 'Astaghfirullah',
      nameAr: 'أستغفر الله',
      transliteration: 'Astaghfirullah',
      traditionalNoteEn:
          'No fixed count is required. Use an unlimited counter or a personal goal.',
      traditionalNoteAr:
          'لا يشترط عدد ثابت. استخدم عدّاداً بلا حد أو هدفاً شخصياً.',
    ),
    TasbeehDhikr(
      id: 'lailahaillallah',
      arabic: 'لَا إِلَهَ إِلَّا اللَّهُ',
      nameEn: 'La ilaha illallah',
      nameAr: 'لا إله إلا الله',
      transliteration: 'La ilaha illallah',
      traditionalNoteEn:
          'No fixed count is required. Use an unlimited counter or a personal goal.',
      traditionalNoteAr:
          'لا يشترط عدد ثابت. استخدم عدّاداً بلا حد أو هدفاً شخصياً.',
    ),
    TasbeehDhikr(
      id: 'hawqala',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      nameEn: 'La hawla wa la quwwata illa billah',
      nameAr: 'لا حول ولا قوة إلا بالله',
      transliteration: 'La hawla wa la quwwata illa billah',
      traditionalNoteEn:
          'No fixed count is required. Use an unlimited counter or a personal goal.',
      traditionalNoteAr:
          'لا يشترط عدد ثابت. استخدم عدّاداً بلا حد أو هدفاً شخصياً.',
    ),
    TasbeehDhikr(
      id: 'salawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      nameEn: 'Salawat on the Prophet',
      nameAr: 'الصلاة على النبي',
      transliteration: 'Allahumma salli ala Muhammad',
      traditionalNoteEn:
          'Encouraged particularly on Friday. No single fixed number is set here as a traditional target.',
      traditionalNoteAr:
          'يُستحب الإكثار منها خاصة يوم الجمعة. لا يُثبت هنا عدد تقليدي ثابت كهدف.',
    ),
  ];
}
