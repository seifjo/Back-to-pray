import '../models/spiritual_journey.dart';

List<List<String>> _repeat(List<List<String>> pattern, int days) {
  return [for (var i = 0; i < days; i++) pattern[i % pattern.length]];
}

class SpiritualJourneyCatalog {
  static final List<SpiritualJourney> all = [
    _journey(
      id: 'prayer_7',
      titleAr: 'ثبات الصلاة في 7 أيام',
      titleEn: '7-day prayer consistency',
      descriptionAr: 'خطة قصيرة لإعادة الصلوات الخمس إلى موضعها من اليوم.',
      descriptionEn: 'A short plan to give the five prayers a steady place in the day.',
      objectiveAr: 'أداء الصلوات الخمس مع حضور، بلا لوم إذا فات يوم.',
      objectiveEn: 'Pray the five prayers with presence, without blame if a day is missed.',
      days: 7,
      icon: '🕌',
      milestones: const [3, 7],
      tasksAr: _repeat(const [
        ['صلّ الصلوات الخمس في وقتها', 'اقرأ أوقات اليوم من شاشة الصلاة'],
        ['توضأ قبل الأذان إن استطعت', 'اترك الهاتف خارج المصلى'],
        ['صلّ ركعتين خفيفتين بعد أذان الظهر إن تيسرت'],
        ['راجع اليوم بهدوء: أي صلاة كانت أيسر؟'],
      ], 7),
      tasksEn: _repeat(const [
        ['Pray the five prayers on time', 'Check today’s times in the prayer screen'],
        ['Make wudu before the adhan when you can', 'Leave the phone outside the prayer space'],
        ['Pray two light rakahs after the Dhuhr adhan if it is easy'],
        ['Review the day gently: which prayer felt easiest?'],
      ], 7),
    ),
    _journey(
      id: 'quran_30',
      titleAr: 'قراءة القرآن في 30 يوماً',
      titleEn: '30-day Quran reading',
      descriptionAr: 'ورد يومي هادئ من المصحف، ولو آيات قليلة.',
      descriptionEn: 'A calm daily portion from the mushaf, even a few verses.',
      objectiveAr: 'فتح المصحف كل يوم بلا إلزام بختم محدد.',
      objectiveEn: 'Open the mushaf every day without requiring a fixed completion.',
      days: 30,
      icon: '📖',
      milestones: const [7, 15, 30],
      tasksAr: _repeat(const [
        ['اقرأ من المصحف بضع دقائق', 'اختر موضعاً هادئاً'],
        ['أعد قراءة آخر ما وقفت عليه'],
        ['اقرأ قياماً أو جلوساً كما تيسر، بنية التدبر'],
      ], 30),
      tasksEn: _repeat(const [
        ['Read from the mushaf for a few minutes', 'Choose a quiet place'],
        ['Reread the last passage you reached'],
        ['Read sitting or standing, as is easy, intending reflection'],
      ], 30),
    ),
    _journey(
      id: 'adhkar_daily',
      titleAr: 'ذكر يومي',
      titleEn: 'Daily Adhkar',
      descriptionAr: 'أذكار الصباح أو المساء من مكتبة التطبيق.',
      descriptionEn: 'Morning or evening Adhkar from the app library.',
      objectiveAr: 'ورد ذكر واحد مكتمل في اليوم.',
      objectiveEn: 'One completed remembrance session each day.',
      days: 14,
      icon: '📿',
      milestones: const [7, 14],
      tasksAr: _repeat(const [
        ['أتمم فئة أذكار الصباح أو المساء', 'احفظ واحداً منها لتعيده في اليوم'],
      ], 14),
      tasksEn: _repeat(const [
        ['Complete the morning or evening Adhkar category', 'Keep one phrase to repeat through the day'],
      ], 14),
    ),
    _journey(
      id: 'repentance',
      titleAr: 'رحلة توبة',
      titleEn: 'A journey of repentance',
      descriptionAr: 'باب التوبة مفتوح. هذه الخطة تعين على الرجوع دون قنوط.',
      descriptionEn: 'The door of repentance is open. This plan supports returning without despair.',
      objectiveAr: 'استغفار صادق مع عمل يقطع العادة الضارة.',
      objectiveEn: 'Sincere istighfar with one action that interrupts a harmful habit.',
      days: 10,
      icon: '💧',
      milestones: const [3, 10],
      tasksAr: _repeat(const [
        ['اقرأ سيد الاستغفار من قسم الاستغفار', 'اترك أحد المحفزات لهذا اليوم'],
        ['صلّ ركعتين بخشوع إن استطعت', 'اذكر نية توبة بلا تفصيل الذنب للناس'],
      ], 10),
      tasksEn: _repeat(const [
        ['Read the master prayer for forgiveness in the Adhkar library', 'Leave one trigger unused today'],
        ['Pray two rakahs with presence if you can', 'Keep the intention private'],
      ], 10),
    ),
    _journey(
      id: 'gratitude',
      titleAr: 'رحلة شكر',
      titleEn: 'A journey of gratitude',
      descriptionAr: 'لاحظ النعم وقل الحمد بشيء تراه.',
      descriptionEn: 'Notice blessings and say alhamdulillah for something you can see.',
      objectiveAr: 'شكر يومي محدد، لا شعور عام فقط.',
      objectiveEn: 'A specific thanks each day, not only a general feeling.',
      days: 7,
      icon: '🌿',
      milestones: const [7],
      tasksAr: _repeat(const [
        ['اكتب نعمة واحدة شهدتها اليوم', 'قل الحمد لله عليها'],
        ['اشكر شخصاً بعبارة طيبة'],
      ], 7),
      tasksEn: _repeat(const [
        ['Name one blessing you noticed today', 'Say alhamdulillah for it'],
        ['Thank one person with a kind sentence'],
      ], 7),
    ),
    _journey(
      id: 'character',
      titleAr: 'تهذيب الخلق',
      titleEn: 'Improving character',
      descriptionAr: 'خلق واحد في كل يوم: صدق، أو حلم، أو كف أذى.',
      descriptionEn: 'One character trait a day: truthfulness, restraint, or withholding harm.',
      objectiveAr: 'عمل خلقي صغير يمكن مراجعته مساءً.',
      objectiveEn: 'A small character action you can review in the evening.',
      days: 14,
      icon: '🤍',
      milestones: const [7, 14],
      tasksAr: _repeat(const [
        ['اصدق في خبر صغير يسهل تزيينه'],
        ['إذا غضبت فاصمت حتى يهدأ النفس'],
        ['اترك غيبة سمعتها دون نقلها'],
      ], 14),
      tasksEn: _repeat(const [
        ['Tell the truth in a small story that would be easy to embellish'],
        ['If anger rises, stay silent until it settles'],
        ['Do not pass on backbiting you heard'],
      ], 14),
    ),
    _journey(
      id: 'hifz',
      titleAr: 'حفظ من قصار السور',
      titleEn: 'Memorizing short surahs',
      descriptionAr: 'كرر السورة من المصحف. التطبيق لا يعرض نصاً بديلاً عن المصحف.',
      descriptionEn: 'Repeat the surah from the mushaf. The app does not replace the written Quran.',
      objectiveAr: 'مراجعة يومية لسورة قصيرة.',
      objectiveEn: 'A daily review of one short surah.',
      days: 7,
      icon: '📚',
      milestones: const [7],
      tasksAr: const [
        ['اقرأ سورة الفاتحة من المصحف وكررها'],
        ['اقرأ سورة الإخلاص من المصحف وكررها'],
        ['اقرأ سورة الفلق من المصحف وكررها'],
        ['اقرأ سورة الناس من المصحف وكررها'],
        ['اقرأ سورة العصر من المصحف وكررها'],
        ['اقرأ سورة الكوثر من المصحف وكررها'],
        ['راجع السور الست من المصحف'],
      ],
      tasksEn: const [
        ['Read Surat al-Fatiha from the mushaf and repeat it'],
        ['Read Surat al-Ikhlas from the mushaf and repeat it'],
        ['Read Surat al-Falaq from the mushaf and repeat it'],
        ['Read Surat an-Nas from the mushaf and repeat it'],
        ['Read Surat al-Asr from the mushaf and repeat it'],
        ['Read Surat al-Kawthar from the mushaf and repeat it'],
        ['Review all six surahs from the mushaf'],
      ],
    ),
    _journey(
      id: 'ramadan_prep',
      titleAr: 'تهيئة لرمضان',
      titleEn: 'Preparing for Ramadan',
      descriptionAr: 'عادة خفيفة قبل الشهر، تصلح في أي وقت من السنة.',
      descriptionEn: 'A light habit before the month. It is useful at any time of year.',
      objectiveAr: 'صيام نافلة اختياري وذكر، بقدر الطاقة.',
      objectiveEn: 'An optional fast and remembrance, within your capacity.',
      days: 10,
      icon: '🌙',
      milestones: const [5, 10],
      tasksAr: _repeat(const [
        ['إن استطعت فصُم يوماً نفلاً، وإلا فأخّر وجبة واحدة بنية التعبّد'],
        ['اقرأ أذكار المساء', 'حدد وقت السحور أو الإفطار في ذهنك تدريباً'],
      ], 10),
      tasksEn: _repeat(const [
        ['Fast an optional day if you are able; otherwise delay one meal as worship'],
        ['Read the evening Adhkar', 'Mentally practice a suhoor or iftar time'],
      ], 10),
    ),
    _journey(
      id: 'good_deeds',
      titleAr: 'عمل صالح يومي',
      titleEn: 'Daily good deeds',
      descriptionAr: 'عمل واحد نافع للناس أو للبيت.',
      descriptionEn: 'One useful act for people or for the home.',
      objectiveAr: 'إحسان صغير متكرر.',
      objectiveEn: 'A small kindness, repeated.',
      days: 7,
      icon: '🌱',
      milestones: const [7],
      tasksAr: _repeat(const [
        ['أعن أحداً في أمر بيتك أو طريقك'],
        ['تصدّق بشيء يسير أو أطعم'],
        ['صل رحمك برسالة طيبة'],
      ], 7),
      tasksEn: _repeat(const [
        ['Help with one task at home or on your way'],
        ['Give a small charity or share food'],
        ['Send a kind message to a relative'],
      ], 7),
    ),
  ];

  static SpiritualJourney? byId(String id) {
    for (final journey in all) {
      if (journey.id == id) return journey;
    }
    return null;
  }

  static SpiritualJourney _journey({
    required String id,
    required String titleAr,
    required String titleEn,
    required String descriptionAr,
    required String descriptionEn,
    required String objectiveAr,
    required String objectiveEn,
    required int days,
    required String icon,
    required List<int> milestones,
    required List<List<String>> tasksAr,
    required List<List<String>> tasksEn,
  }) {
    return SpiritualJourney(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      objectiveAr: objectiveAr,
      objectiveEn: objectiveEn,
      durationDays: days,
      icon: icon,
      milestones: milestones,
      tasksAr: tasksAr.map((day) => List<String>.from(day)).toList(),
      tasksEn: tasksEn.map((day) => List<String>.from(day)).toList(),
    );
  }
}
