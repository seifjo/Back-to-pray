# -*- coding: utf-8 -*-
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "lib" / "l10n" / "app_localizations.dart"
text = p.read_text(encoding="utf-8")
lines = text.splitlines(keepends=True)

start = None
end = None
for i, line in enumerate(lines):
    if start is None and line.strip().startswith("'asmaTitle':") and "أسماء الله الحسنى" in line:
        start = i
        continue
    if start is not None and "'asmaMarkReviewed'" in line:
        end = i
        break

print("start", start, "end", end)
if start is None or end is None:
    raise SystemExit("markers not found")

new_block = """    'asmaTitle': 'أسماء الله الحسنى',
    'asmaSubtitle':
        'الترتيب الأساسي وفق سرد قرآني تعليمي (سورة قرآن). الأسماء المركبة وأسماً من السنة في أقسام منفصلة. لا يُعرض بوصفه السرد الوحيد.',
    'asmaSearchHint': 'ابحث بالعربية أو النقل أو المعنى',
    'asmaAll': 'الكل',
    'asmaPrimary99': 'الترتيب ١–٩٩',
    'asmaCompound': 'المركّبة (قرآن)',
    'asmaSunnahExtra': 'من السنة',
    'asmaFavorites': 'المفضلة',
    'asmaFavorite': 'المفضلة',
    'asmaLearningMode': 'وضع التعلّم',
    'asmaProgress': 'راجعت {reviewed} من {total}',
    'asmaEmpty': 'لا يوجد اسم مطابق لبحثك أو عوامل التصفية.',
    'asmaLoadError': 'تعذر تحميل أسماء الله الحسنى.',
    'asmaMissing': 'هذا الاسم غير متوفر.',
    'asmaSourceQuran': 'من القرآن',
    'asmaSourceSunnah': 'من السنة',
    'asmaExplanation': 'شرح الاسم ومعناه',
    'asmaSource': 'نسبة المصدر',
    'asmaOpenSourcePage': 'فتح صفحة المصدر',
    'asmaArtwork': 'لوحة كل الأسماء',
    'asmaArtworkTitle': 'أسماء الله الحسنى — لوحة',
    'asmaArtworkHelp': 'قرّب بإصبعيك. للتفسير افتح الاسم من قائمة المكتبة.',
    'asmaArtworkNote':
        'عرض تزييني فقط. الدراسة التفاعلية عبر القائمة وصفحات التفاصيل.',
    'asmaArtworkMissing': 'صورة اللوحة غير متوفرة على هذا الجهاز.',
    'asmaRelated': 'أسماء ذات صلة',
    'asmaNoRelated': 'لا توجد أسماء ذات صلة حالياً.',
    'asmaShare': 'مشاركة',
    'asmaCopy': 'نسخ',
    'asmaCopied': 'تم نسخ الاسم',
    'asmaReviewed': 'تمت المراجعة',
    'asmaMarkReviewed': 'علم كمراجع',
""".splitlines(keepends=True)

out = lines[:start] + new_block + lines[end + 1 :]
p.write_text("".join(out), encoding="utf-8")
print("patched ok")
