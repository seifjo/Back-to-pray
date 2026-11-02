"""Build Nawawi explanation JSON from Ibn Daqiq al-'Id's classical Arabic sharh.

Source: شرح الأربعين النووية لابن دقيق العيد (d. 702 AH / 1302 CE) — public domain.
OCR text was retrieved from a published Arabic PDF transcription; light normalization
only (e.g. االله → الله). No English commentary is invented or copied from modern works.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ORDINALS = {
    "الأول": 1,
    "الثاني": 2,
    "الثالث": 3,
    "الرابع": 4,
    "الخامس": 5,
    "السادس": 6,
    "السابع": 7,
    "الثامن": 8,
    "التاسع": 9,
    "العاشر": 10,
    "الحادي عشر": 11,
    "الثانى عشر": 12,
    "الثاني عشر": 12,
    "الثالث عشر": 13,
    "الرابع عشر": 14,
    "الخامس عشر": 15,
    "السادس عشر": 16,
    "السابع عشر": 17,
    "الثامن عشر": 18,
    "التاسع عشر": 19,
    "العشرون": 20,
    "الحادي والعشرون": 21,
    "الثاني والعشرون": 22,
    "الثانى والعشرون": 22,
    "الثالث والعشرون": 23,
    "الرابع والعشرون": 24,
    "الخامس والعشرون": 25,
    "السادس والعشرون": 26,
    "الساد س والثلاثون": 36,
    "السابع والعشرون": 27,
    "الثامن والعشرون": 28,
    "التاسع والعشرون": 29,
    "الثلاثون": 30,
    "الثلا ثون": 30,
    "الحادي والثلاثون": 31,
    "الثاني والثلاثون": 32,
    "الثالث والثلاثون": 33,
    "الرابع والثلاثون": 34,
    "الخامس والثلاثون": 35,
    "السادس والثلاثون": 36,
    "السابع والثلاثون": 37,
    "الثامن والثلاثون": 38,
    "التاسع والثلاثون": 39,
    "الأربعون": 40,
    "الحادي والأربعون": 41,
    "الثاني والأربعون": 42,
}


def normalize(text: str) -> str:
    text = text.replace("االله", "الله")
    text = text.replace("االلَّه", "الله")
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    text = re.sub(r"[ \t]{2,}", " ", text)
    return text.strip()


def split_hadiths(raw: str) -> dict[int, str]:
    pattern = re.compile(
        r"الحديث\s+("
        + "|".join(sorted((re.escape(k) for k in ORDINALS), key=len, reverse=True))
        + r")\s*"
    )
    matches = list(pattern.finditer(raw))
    parts: dict[int, str] = {}
    for index, match in enumerate(matches):
        label = match.group(1).strip()
        number = ORDINALS.get(label)
        if number is None:
            continue
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(raw)
        body = normalize(raw[start:end])
        if len(body) < 40:
            continue
        parts[number] = body
    return parts


def main() -> None:
    source = Path(
        r"C:\Users\Saif\.cursor\projects\c-DEV-Back-to-pray-update\agent-tools\8189df4b-1325-4c80-b8e7-dabd4386861d.txt"
    )
    raw = source.read_text(encoding="utf-8", errors="ignore")
    parts = split_hadiths(raw)
    explanations = []
    for number in range(1, 43):
        arabic = parts.get(number, "").strip()
        if not arabic:
            continue
        explanations.append(
            {
                "hadithId": f"nawawi:{number}",
                "available": True,
                "authorAr": "ابن دقيق العيد",
                "authorEn": "Ibn Daqiq al-‘Id",
                "sourceBookAr": "شرح الأربعين النووية",
                "sourceBookEn": "Commentary on an-Nawawi’s Forty Hadith",
                "sourceReference": f"Hadith {number}",
                "licenseNote": (
                    "Classical Arabic commentary by Ibn Daqiq al-‘Id "
                    "(d. 702 AH / 1302 CE). Public domain by age. "
                    "Modern English commentaries are not bundled."
                ),
                "scholarlyArabic": arabic,
                "scholarlyEnglish": "",
                "vocabulary": [],
                "contextAr": "",
                "contextEn": "",
                "lessonsAr": [],
                "lessonsEn": [],
                "applicationAr": "",
                "applicationEn": "",
                "summaryNoteEn": (
                    "The Arabic section below is the classical commentary. "
                    "No modern English explanation is included in this release "
                    "because redistributable licensing was not confirmed."
                ),
                "summaryNoteAr": (
                    "النص العربي أدناه من الشرح الكلاسيكي. "
                    "لا تتضمن هذه النسخة شرحاً إنجليزياً حديثاً لعدم ثبوت إذن إعادة النشر."
                ),
            }
        )

    out = {
        "_meta": {
            "source": "Ibn Daqiq al-‘Id, Sharh al-Arba‘in al-Nawawiyya",
            "language": "ar",
            "license": "Public domain (classical author d. 702 AH)",
            "limitation": (
                "English scholarly explanations from modern books "
                "(e.g. Badi, Zarabozo) are copyrighted and are not bundled."
            ),
            "count": len(explanations),
        },
        "explanations": explanations,
    }
    target = Path("assets/hadith/explanations.json")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
    print("wrote", target, "count", len(explanations), "missing", sorted(set(range(1, 43)) - set(parts)))


if __name__ == "__main__":
    main()
