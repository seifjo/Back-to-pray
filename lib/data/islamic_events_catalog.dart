import '../models/hijri_calendar.dart';

/// Islamic occasions defined by Hijri month/day rules (Umm al-Qura convention).
///
/// Gregorian dates are computed each year—never hardcoded permanently.
/// Observance of some occasions (e.g. Mawlid) differs among communities;
/// they are listed as calendar markers, not as religious rulings.
class IslamicEventsCatalog {
  static const definitions = <IslamicEventDefinition>[
    IslamicEventDefinition(
      id: 'new_year',
      hijriMonth: 1,
      hijriDay: 1,
      nameEn: 'Islamic New Year',
      nameAr: 'رأس السنة الهجرية',
      descriptionEn:
          '1 Muharram — the beginning of the Hijri year on this calendar.',
      descriptionAr: '١ محرم — بداية السنة الهجرية وفق هذا التقويم.',
      colorValue: 0xFF0D7377,
    ),
    IslamicEventDefinition(
      id: 'ashura',
      hijriMonth: 1,
      hijriDay: 10,
      nameEn: 'Ashura',
      nameAr: 'يوم عاشوراء',
      descriptionEn:
          '10 Muharram — a significant day; fasting on Ashura is reported in authentic hadith.',
      descriptionAr:
          '١٠ محرم — يوم عظيم؛ ورد صيام عاشوراء في الأحاديث الصحيحة.',
      colorValue: 0xFF8B6F47,
    ),
    IslamicEventDefinition(
      id: 'mawlid',
      hijriMonth: 3,
      hijriDay: 12,
      nameEn: 'Mawlid (Rabiʿ al-Awwal 12)',
      nameAr: 'المولد (١٢ ربيع الأول)',
      descriptionEn:
          '12 Rabiʿ al-Awwal on this calendar. Observance practices differ; shown as a date marker only.',
      descriptionAr:
          '١٢ ربيع الأول وفق هذا التقويم. تختلف ممارسات المجتمعات؛ يُعرض كعلامة تاريخية فقط.',
      colorValue: 0xFFC9A227,
    ),
    IslamicEventDefinition(
      id: 'isra_miraj',
      hijriMonth: 7,
      hijriDay: 27,
      nameEn: 'Isra and Miʿraj (commonly marked)',
      nameAr: 'الإسراء والمعراج (شائع التعيين)',
      descriptionEn:
          '27 Rajab is commonly used to mark the occasion on civil Islamic calendars; the exact historical night is not unanimously fixed.',
      descriptionAr:
          '٢٧ رجب شائع لتعيين المناسبة في التقاويم المدنية؛ الليلة التاريخية غير متفق على تعيينها قطعاً.',
      colorValue: 0xFF6B5B95,
    ),
    IslamicEventDefinition(
      id: 'ramadan_start',
      hijriMonth: 9,
      hijriDay: 1,
      nameEn: 'Ramadan begins',
      nameAr: 'بداية رمضان',
      descriptionEn:
          '1 Ramadan on the Umm al-Qura calendar. Local moon-sighting may differ by a day.',
      descriptionAr:
          '١ رمضان وفق تقويم أم القرى. قد يختلف الرؤية المحلية بيوم.',
      colorValue: 0xFF5B8C5A,
    ),
    IslamicEventDefinition(
      id: 'laylat_al_qadr',
      hijriMonth: 9,
      hijriDay: 27,
      nameEn: 'Laylat al-Qadr (commonly 27th)',
      nameAr: 'ليلة القدر (شائع: ٢٧)',
      descriptionEn:
          'Often marked on 27 Ramadan for planning. The exact night is among the last ten odd nights of Ramadan.',
      descriptionAr:
          'يُعلَّم غالباً في ٢٧ رمضان للتخطيط. الليلة في العشر الأواخر في الليالي الوترية.',
      colorValue: 0xFFD4AF37,
    ),
    IslamicEventDefinition(
      id: 'eid_fitr',
      hijriMonth: 10,
      hijriDay: 1,
      nameEn: 'Eid al-Fitr',
      nameAr: 'عيد الفطر',
      descriptionEn:
          '1 Shawwal — Eid following Ramadan on this calendar.',
      descriptionAr: '١ شوال — عيد الفطر وفق هذا التقويم.',
      colorValue: 0xFF14A3A8,
    ),
    IslamicEventDefinition(
      id: 'arafah',
      hijriMonth: 12,
      hijriDay: 9,
      nameEn: 'Day of Arafah',
      nameAr: 'يوم عرفة',
      descriptionEn:
          '9 Dhul-Hijjah — the day of Arafah; fasting for non-pilgrims is widely recommended.',
      descriptionAr:
          '٩ ذو الحجة — يوم عرفة؛ يُستحب صيامه لغير الحاج.',
      colorValue: 0xFF45B8AC,
    ),
    IslamicEventDefinition(
      id: 'eid_adha',
      hijriMonth: 12,
      hijriDay: 10,
      nameEn: 'Eid al-Adha',
      nameAr: 'عيد الأضحى',
      descriptionEn:
          '10 Dhul-Hijjah — Eid al-Adha on this calendar.',
      descriptionAr: '١٠ ذو الحجة — عيد الأضحى وفق هذا التقويم.',
      colorValue: 0xFFB42318,
    ),
  ];

  static IslamicEventDefinition? byId(String id) {
    for (final item in definitions) {
      if (item.id == id) return item;
    }
    return null;
  }
}
