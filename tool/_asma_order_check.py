# -*- coding: utf-8 -*-
import re
from pathlib import Path

out = Path(r"c:\DEV\Back to pray _update\tool\_asma_order_report.txt")
text = Path(r"c:\DEV\Back to pray _update\lib\data\asma_ul_husna.dart").read_text(encoding="utf-8")
blocks = re.findall(
    r"DivineName\(\s*id: '([^']+)',\s*index: \d+,\s*arabic: '([^']+)'",
    text,
)
by_ar = {ar: id_ for id_, ar in blocks}

traditional = [
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

lines = []
lines.append(f"catalog={len(blocks)}")
matched_ids = []
for i, ar in enumerate(traditional, 1):
    if ar in by_ar:
        matched_ids.append(by_ar[ar])
        lines.append(f"OK {i:02d} {by_ar[ar]}")
    else:
        lines.append(f"MISS {i:02d}")

used = set(matched_ids)
remaining = [id_ for id_, _ in blocks if id_ not in used]
lines.append(f"matched={len(matched_ids)} remaining={len(remaining)}")
lines.append("ORDER_IDS=" + ",".join(matched_ids + remaining))
lines.append("REMAINING=" + ",".join(remaining))
out.write_text("\n".join(lines), encoding="utf-8")
print("wrote report matched=%d remaining=%d" % (len(matched_ids), len(remaining)))
