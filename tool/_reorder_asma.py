# -*- coding: utf-8 -*-
"""Reorder Asma Ul Husna catalog to canonical traditional display order.

Content (meanings/explanations/evidence) stays from Ibn Uthaymeen's list.
Indices are rewritten 1..99 for the stable display order starting with الرحمن.
Names unique to the verified source follow after the traditional matching sequence.
"""
import re
from pathlib import Path

root = Path(r"c:\DEV\Back to pray _update")
src = root / "lib" / "data" / "asma_ul_husna.dart"
text = src.read_text(encoding="utf-8")

# Split preamble and list body
marker = "static const all = <DivineName>["
start = text.index(marker) + len(marker)
# Find closing of all list: "  ];\n\n  static DivineName?"
end_marker = "\n  ];\n\n  static DivineName?"
end = text.index(end_marker, start)
preamble = text[:start]
postamble = text[end:]

body = text[start:end]
# Split DivineName entries by looking for "    DivineName("
parts = re.split(r"(?=    DivineName\()", body)
entries = [p for p in parts if p.strip().startswith("DivineName(")]

by_id = {}
for entry in entries:
    m = re.search(r"id: '([^']+)'", entry)
    if not m:
        raise SystemExit("missing id in entry")
    by_id[m.group(1)] = entry

traditional_ar = [
    "الرحمن", "الرحيم", "الملك", "القدوس", "السلام", "المؤمن", "المهيمن", "العزيز", "الجبار", "المتكبر",
    "الخالق", "البارئ", "المصور", "الغفار", "القهار", "الوهاب", "الرزاق", "الفتاح", "العليم", "القابض",
    "الباسط", "الخافض", "الرافع", "المعز", "المذل", "السميع", "البصير", "الحكم", "العدل", "اللطيف",
    "الخبير", "الحليم", "العظيم", "الغفور", "الشكور", "العلي", "الكبير", "الحفيظ", "المقيت", "الحسيب",
    "الجليل", "الكريم", "الرقيب", "المجيب", "الواسع", "الحكيم", "الودود", "المجيد", "الباعث", "الشهيد",
    "الحق", "الوكيل", "القوي", "المتين", "الولي", "الحميد", "المحصي", "المبدئ", "المعيد", "المحيي",
    "المميت", "الحي", "القيوم", "الواجد", "الماجد", "الواحد", "الأحد", "الصمد", "القادر", "المقتدر",
    "المقدم", "المؤخر", "الأول", "الآخر", "الظاهر", "الباطن", "الوالي", "المتعالي", "البر", "التواب",
    "المنتقم", "العفو", "الرؤوف", "مالك الملك", "ذو الجلال والإكرام", "المقسط", "الجامع", "الغني", "المغني", "المانع",
    "الضار", "النافع", "النور", "الهادي", "البديع", "الباقي", "الوارث", "الرشيد", "الصبور",
]

# Map arabic -> id from current entries
ar_to_id = {}
for id_, entry in by_id.items():
    am = re.search(r"arabic: '([^']+)'", entry)
    ar_to_id[am.group(1)] = id_

ordered_ids = []
for ar in traditional_ar:
    if ar in ar_to_id:
        ordered_ids.append(ar_to_id[ar])

used = set(ordered_ids)
# Preserve relative source order for remaining verified-source-only names
original_ids = list(by_id.keys())  # insertion order from file parse - may be wrong
# Better: extract original order from entries list
original_ids = []
for entry in entries:
    m = re.search(r"id: '([^']+)'", entry)
    original_ids.append(m.group(1))

for id_ in original_ids:
    if id_ not in used:
        ordered_ids.append(id_)

assert len(ordered_ids) == 99, len(ordered_ids)
assert len(set(ordered_ids)) == 99

rewritten = []
for index, id_ in enumerate(ordered_ids, 1):
    entry = by_id[id_]
    entry = re.sub(r"index: \d+", f"index: {index}", entry, count=1)
    # Ensure trailing comma between entries
    entry = entry.rstrip()
    if not entry.endswith(","):
        entry = entry + ","
    rewritten.append("\n    " + entry.lstrip() if not entry.startswith("\n") else entry)
    # normalize leading whitespace
    if not rewritten[-1].startswith("\n    DivineName"):
        rewritten[-1] = "\n    " + rewritten[-1].lstrip()

new_body = "".join(rewritten)

# Update attribution to mention canonical display order
old_attr_en = (
    "Collection: Ibn Uthaymeen's Al-Qawa'id al-Muthla (81 Quranic, 18 Sunnah). "
    "The authentic hadith in Bukhari and Muslim affirms ninety-nine Names without "
    "listing them. The popular ordered list linked to some Tirmidhi narrations is "
    "not treated here as an authenticated prophetic enumeration. Meanings are brief "
    "lexical/theological glosses for learning—not exhaustive creed treatises."
)
new_attr_en = (
    "Collection: Ibn Uthaymeen's Al-Qawa'id al-Muthla (81 Quranic, 18 Sunnah). "
    "Display order follows the widely used canonical sequence beginning with "
    "Ar-Rahmaan, Ar-Raheem, Al-Malik…; Names unique to this verified compilation "
    "follow after that sequence. The Bukhari/Muslim hadith affirms ninety-nine Names "
    "without listing them. Meanings are brief lexical/theological glosses for "
    "learning—not exhaustive creed treatises."
)
old_attr_ar = (
    "المصدر: القواعد المثلى للشيخ ابن عثيمين (٨١ من القرآن و١٨ من السنة). "
    "حديث البخاري ومسلم يثبت أن لله تسعة وتسعين اسماً دون سردها. القائمة الشهيرة "
    "المنسوبة لبعض روايات الترمذي لا تُعرض هنا كسرد نبوي ثابت. المعاني مختصرة للتعليم."
)
new_attr_ar = (
    "المصدر: القواعد المثلى للشيخ ابن عثيمين (٨١ من القرآن و١٨ من السنة). "
    "ترتيب العرض يتبع التسلسل المتعارف عليه بدءًا من الرحمن والرحيم والملك…، "
    "ثم تُلحق الأسماء الخاصة بهذه المجموعة الموثّقة. حديث البخاري ومسلم يثبت "
    "تسعة وتسعين اسماً دون سردها. المعاني مختصرة للتعليم."
)

preamble2 = preamble.replace(old_attr_en, new_attr_en).replace(old_attr_ar, new_attr_ar)

# Also update the doc comment above the class if present
preamble2 = preamble2.replace(
    "and it is not the disputed enumeration attached to some Tirmidhi wordings.",
    "Display uses the familiar ordered sequence (starting with الرحمن) while "
    "keeping this compilation's verified meanings and attributions.",
)

final = preamble2 + new_body + postamble
src.write_text(final, encoding="utf-8")

# Verify first 10
check = src.read_text(encoding="utf-8")
first = re.findall(
    r"DivineName\(\s*id: '([^']+)',\s*index: (\d+),\s*arabic: '([^']+)'",
    check,
)[:10]
report = root / "tool" / "_asma_reorder_done.txt"
first_lines = "\n".join(f"{idx} {id_} {ar}" for id_, idx, ar in first)
all_section = check[check.index("static const all") : check.index("static DivineName?")]
total = len(re.findall(r"id: '", all_section))
report.write_text(first_lines + f"\nTOTAL={total}", encoding="utf-8")
print("done first10 ids=", [id_ for id_, _, _ in first], "total", total)
